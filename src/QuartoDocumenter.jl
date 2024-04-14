module QuartoDocumenter

using Quarto
using Markdown
using InteractiveUtils

function mcat(m1::Markdown.MD, m2::Markdown.MD; delimiter="{{< pagebreak >}}")
    return Markdown.MD(m1, delimiter, m2)
end

function autodocs(mod::Module, lvalues...)
    names = isempty(lvalues) ? Base.names(mod) : collect(lvalues)
    return mapreduce(name -> doc(name), mcat, names)
end

macro autodocs(lvalues...)
    return quote
        autodocs(@__MODULE__, $(lvalues...))
    end
end

macro autodocs(lvalues)
    return quote
        autodocs(@__MODULE__, $(lvalues)...)
    end
end

function increase_header_levels(str::AbstractString)
    lines = collect(eachline(IOBuffer(str)))
    for index in CartesianIndices(lines)
        line = lines[index]
        words = split(line)
        if !isempty(words)
            word = first(words)
            if word in ("###", "##", "#")
                lines[index] = "###$(line)"
            elseif word in ("####", "#####", "######")
                lines[index] = "**$(lstrip(replace(line, word => "")))**"
            end
        end
    end

    return join(lines, "\n")
end

function doc(mod::Module, sym::Symbol)
    parent = parentmodule(getproperty(mod, sym))
    docmkd = Base.Docs.doc(Docs.Binding(parent, symbol))
    docstr = increase_header_levels(string(docmkd))
    return Markdown.MD(docstr)
end

function doc(any::Any)
    docmkd = Base.Docs.doc(any)
    docstr = increase_header_levels(string(docmkd))
    return Markdown.MD(docstr)
end

end # module QuartoDocumenter