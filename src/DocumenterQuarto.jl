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

    src::String = joinpath(docs, "src")
    isdir(src) || mkdir(src)

    _quarto = joinpath(src, "_quarto.yml")

    repo = let
        capture = IOCapture.capture() do
            run(`$(git()) remote get-url origin`)
        end
        replace(strip(capture.output), ".git" => "", "https://" => "", "http://" => "", "www." => "")
    end

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
                output-dir: ../build

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
                    theme:
                        light: flatly
                        dark: darkly
            """
        )
    end

    references = joinpath(src, "references.bib")
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

    index = joinpath(src, "index.md")

    isfile(index) || begin
        if isfile("README.md")
            open(index, "w") do io
                write(
                    io,
                    """
                    ---
                    title: Overview
                    ---

                    {{< include ../../README.md >}}
                    """
                )
            end
        else
            open(index, "w") do io
                write(
                    io,
                    """
                    # Overview

                    _To do: add a description of the project!_
                    """
                )
            end
        end
    end

    project = joinpath(docs, "Project.toml")
    isfile(project) || open(project, "w") do io
        write(
            io,
            """
            [deps]
            Documenter = "e30172f5-a6a5-5a46-863b-614d45cd2de4"
            Quarto = "d7167be5-f61b-4dc9-b75c-ab62374668c5"
            DocumenterQuarto = "73f83fcb-c367-40db-89b6-8fd94701aaf2"
            IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
            """
        )
    end

    if !isnothing(api)
        api = joinpath(src, "api")
        isdir(api) || mkdir(api)

        api = joinpath(api, "index.qmd")
        isfile(api) || open(api, "w") do io
            write(
                io,
                """
                ---
                number-depth: 2
                ---

                # Reference

                _Docstrings for $name._

                ```{julia}
                #| echo: false
                #| output: false
                using DocumenterQuarto
                using $name
                ```

                ```{julia}
                #| echo: false
                #| output: asis
                DocumenterQuarto.autodoc($name)
                ```
                """
            )
        end

    end

    make = joinpath(docs, "make.jl")
    isfile(make) || open(make, "w") do io
        write(
            io,
            """
            using Documenter
            using Quarto

            Quarto.render(joinpath(@__DIR__, "src"))

            Documenter.deploydocs(repo = "$repo")
            """
        )
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
            markdown.content[index] = Markdown.Header{newlevel}(vcat(item.text, " {.unnumbered}"))
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
    if :content in propertynames(markdown)
        elements = markdown.content
    else
        elements = markdown.items
    end

    for (index, item) in enumerate(elements)
        if item isa AbstractVector
            elements[index] = process_xref.(item)
        elseif item isa Markdown.Link
            if occursin("@ref", item.url)
                item.url = "#" * strip(
                    replace(
                        mapreduce(x -> string(Markdown.MD(x)), *, item.text),
                        "`" => "",
                    )
                )
                elements[index] = item
            end
        elseif :content in propertynames(item) || :items in propertynames(item)
            elements[index] = process_xref(item)
        end
    end

    if :content in propertynames(markdown)
        markdown.content = elements
    else
        markdown.items = elements
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