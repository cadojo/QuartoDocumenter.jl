module QuartoDocumenter

using Quarto
using Markdown
using InteractiveUtils

function autodoc(mod::Module, symbols::Symbol...; delimiter=md"{{< pagebreak >}}")
    svec = isempty(symbols) ? Base.names(mod) : symbols
    return Markdown.MD(map(name -> Markdown.MD(doc(mod, name), delimiter), svec)...)
end

macro autodoc(lvalues...)
    return quote
        autodoc(@__MODULE__, $(lvalues...))
    end
end

macro autodocs(lvalues)
    return quote
        autodoc(@__MODULE__, $(lvalues)...)
    end
end

level(::Markdown.Header{T}) where {T} = T

function process_headers(markdown)
    for (index, item) in enumerate(markdown.content)
        if item isa Markdown.Header
            newlevel = min(level(item) + 3, 6)
            markdown.content[index] = Markdown.Header{newlevel}(item.text)
        elseif :content in propertynames(item)
            markdown.content[index] = process_headers(item)
        end
    end
    return markdown
end

function process_admonitions(markdown)
    for (index, item) in enumerate(markdown.content)
        if item isa Markdown.Admonition
            markdown.content[index] = Markdown.MD(
                Markdown.parse(""":::{.callout-$(item.category) title="$(item.title)"}"""),
                item.content...,
                md":::",
            )
        elseif :content in propertynames(item)
            markdown.content[index] = process_admonitions(item)
        end
    end
    return markdown
end

function process_xref(markdown)
    for (index, item) in enumerate(markdown.content)
        if item isa Markdown.Link
            markdown.content[index] = Markdown.MD(item.text)
        elseif :content in propertynames(item)
            markdown.content[index] = process_xref(item)
        end
    end
    return markdown
end

function doc(mod::Module, sym::Symbol)
    parent = which(mod, sym)
    docmkd = Base.Docs.doc(Docs.Binding(parent, sym))
    return doc(docmkd)
end

function doc(any::Any)
    docmkd = Base.Docs.doc(any)
    return doc(docmkd)
end

function doc(md::Markdown.MD)
    processed = (
        md
        |> process_headers
        |> process_admonitions
        |> process_xref
    )
    return Markdown.MD(
        Markdown.parse(""":::{.callout appearance="simple"}"""),
        processed,
        md":::"
    )
end

end # module QuartoDocumenter