"""
Utilities and templates for documenting your Julia package with Quarto!

# Exports
$(EXPORTS)
"""
module DocumenterQuarto

export doc, autodoc

using Quarto
using Markdown
using InteractiveUtils
import TOML
using IOCapture
using Git
using Dates

using DocStringExtensions

@template DEFAULT = """
                    $(SIGNATURES)
                    $(DOCSTRING)
                    """

"""
Generate a documentation site from a default template.
"""
function generate(; title=nothing, type="book", api="api")

    name::Union{String,Nothing} = nothing
    if isnothing(title)
        if isfile("Project.toml")
            name = TOML.parsefile("Project.toml")["name"]
        end

        title = isnothing(name) ? "Documentation" : name
    end

    docs::String = joinpath("docs")
    isdir(docs) || mkdir(docs)


    _quarto = joinpath(docs, "_quarto.yml")

    author = let
        capture = IOCapture.capture() do
            run(`$(git()) config user.name`)
        end
        strip(capture.output)
    end

    email = let
        capture = IOCapture.capture() do
            run(`$(git()) config user.email`)
        end
        strip(capture.output)
    end

    isfile(_quarto) || open(_quarto, "w") do io
        write(
            io,
            """
            project:
                type: $type

            $type:
                title: "$title"
                author: 
                    name: "$author"
                    email: "$email"
                date: "$(today())"
                chapters:
                    - index.md
                    $(isnothing(api) ? "" : "- api/index.qmd") 

            toc-title: "Table of Contents"

            execute:
                echo: false
                output: true
                cache: false
                freeze: false

            bibliography: references.bib

            format:
                html:
                    theme: darkly
            """
        )
    end

    references = joinpath(docs, "references.bib")
    isfile(references) || open(references, "w") do io
        write(
            io,
            """
            @software{Allaire_Quarto_2024,
                author = {Allaire, J.J. and Teague, Charles and Scheidegger, Carlos and Xie, Yihui and Dervieux, Christophe},
                doi = {10.5281/zenodo.5960048},
                month = feb,
                title = {{Quarto}},
                url = {https://github.com/quarto-dev/quarto-cli},
                version = {1.4},
                year = {2024}
            }
            """
        )
    end

    index = joinpath(docs, "index.md")

    isfile(index) || open(index, "w") do io
        write(
            io,
            """
            # Overview

            _To do: add a description of the project!_
            """
        )
    end

    project = joinpath(docs, "Project.toml")
    isfile(project) || open(project, "w") do io
        write(
            io,
            """
            [deps]
            DocumenterQuarto = "73f83fcb-c367-40db-89b6-8fd94701aaf2"
            IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
            """
        )
    end

    if !isnothing(api)
        api = joinpath("docs", "api")
        isdir(api) || mkdir(api)

        api = joinpath(api, "index.qmd")
        isfile(api) || open(api, "w") do io
            write(
                io,
                """
                # API Reference

                ```{julia}
                #| echo: false
                #| output: false
                using DocumenterQuarto
                using $name
                ```

                ```{julia}
                #| echo: false
                #| output: true
                DocumenterQuarto.autodoc($name)
                ```
                """
            )
        end

    end

    return nothing
end

"""
Automatically process and return documentation for symbols in the provided 
module. If no symbols are provided, all exported symbols are used. The 
`delimiter` keyword argument is printed in between each documented name.
"""
function autodoc(mod::Module, symbols::Symbol...; delimiter=md"{{< pagebreak >}}")
    svec = isempty(symbols) ? Base.names(mod) : symbols
    return Markdown.MD(map(name -> Markdown.MD(doc(getproperty(mod, name)), delimiter), svec)...)
end

"""
Automatically process and return documentation for all provided names in the 
current module.
"""
macro autodoc(lvalues...)
    return quote
        autodoc(@__MODULE__, $(lvalues...))
    end
end

"""
Automatically process and return documentation for the iterable of provided
names in the current module.
"""
macro autodoc(lvalues)
    return quote
        autodoc(@__MODULE__, $(lvalues)...)
    end
end

level(::Markdown.Header{T}) where {T} = T

function process_headers(markdown)
    for (index, item) in enumerate(markdown.content)
        if item isa Markdown.Header
            newlevel = min(level(item) + 2, 6)
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
            @warn item
            markdown.content[index] = Markdown.MD(item.text)
        elseif :content in propertynames(item)
            @info item
            markdown.content[index] = process_xref(item)
        end
    end
    return markdown
end

function process(markdown)
    return (
        markdown
        |> process_headers
        |> process_admonitions
        |> process_xref
    )
end

"""
Return the documentation string associated with the provided name, with 
substitutions to allow for compatibility with [Quarto](https://quarto.org).
"""
function doc(mod::Module, sym::Symbol)
    parent = which(mod, sym)
    docmkd = Base.Docs.doc(Docs.Binding(parent, sym))
    return doc(docmkd)
end

"""
Return the documentation string associated with the provided value, with 
substitutions to allow for compatibility with [Quarto](https://quarto.org).
"""
function doc(any::Any)
    docmkd = process(
        Base.Docs.doc(any)
    )

    return Markdown.MD(
        Markdown.parse(
            """
            ## `$(nameof(any))`
            :::{.callout appearance="minimal"}
            """
        ),
        docmkd,
        md"""
        :::
        """
    )
end

end # module QuartoDocumenter