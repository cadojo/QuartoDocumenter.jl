module DocumenterQuarto

using Quarto
using Markdown
using InteractiveUtils
import TOML
using IOCapture
using Git
using Dates

function generate(; title=nothing, type="book", api="api")

    if isnothing(title)
        if isfile("Project.toml")
            name = TOML.parsefile("Project.toml")["name"]
        else
            name = nothing
        end

        title = isnothing(name) ? "Documentation" : name
    end

    docs = joinpath("docs")
    isdir(docs) || let
        mkdir(docs)
        run(`julia -e 'import Pkg; Pkg.activate($docs); Pkg.add("DocumenterQuarto")'`)
    end

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
                author: "$author"
                email: "$email"
                date: "$(today())"
                chapters:
                    - index.md
                    $(isnothing(api) ? "" : "- api/index.qmd") 

            bibliography: references.bib

            format:
                html:
                    theme: cosmo
                pdf:
                    documentclass: extarticle
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

    if !isnothing(api)
        api = joinpath("docs", "api")
        isdir(api) || mkdir(api)

        run(`julia -e 'import Pkg; Pkg.activate("docs"); Pkg.develop("$name")'`)

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
end

function autodoc(mod::Module, symbols::Symbol...; delimiter=md"{{< pagebreak >}}")
    svec = isempty(symbols) ? Base.names(mod) : symbols
    return Markdown.MD(map(name -> Markdown.MD(doc(getproperty(mod, name)), delimiter), svec)...)
end

macro autodoc(lvalues...)
    return quote
        autodoc(@__MODULE__, $(lvalues...))
    end
end

macro autodoc(lvalues)
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
function doc end

function doc(mod::Module, sym::Symbol)
    parent = which(mod, sym)
    docmkd = copy(Base.Docs.doc(Docs.Binding(parent, sym)))
    return doc(docmkd)
end

function doc(any::Any)
    docmkd = process(
        copy(Base.Docs.doc(any))
    )

    return Markdown.MD(
        Markdown.parse(
            """
            ## `$(nameof(any))`
            :::{.callout-note appearance="simple"}
            """
        ),
        docmkd,
        md"""
        :::
        """
    )
end

end # module QuartoDocumenter