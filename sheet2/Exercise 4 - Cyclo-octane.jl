using Pkg
using DelimitedFiles

#Pkg.add("Eirene")
#Pkg.add("WebIO")
#Pkg.add("Plots")

using Eirene
using Plots

M_tiny = readdlm("M_tiny.txt", '\t', Float16, '\n')
M_medium = readdlm("M_medium.txt", '\t', Float16, '\n')
M_large = readdlm("M_large.txt", '\t', Float16, '\n')

function get_multidim_persistence_diagram(eirene_output, max_dim=2)
    pd_points = Dict()
    for i in 0:max_dim
        points = barcode(eirene_output, dim=i)
        push!(pd_points, i => points)
    end
    return pd_points
end

function plot_persistence_diagram(pd_points, pdf_output_file)
    markercolors = [
    :green, :orange, :black, :purple,
    :red,   :yellow, :brown, :white
    ]
    x_y_s = []
    max_y = -1
    for dim in 0:(length(pd_points)-1)
        x = []
        y = []
        for row_idx in 1:size(pd_points[dim])[1]
            push!(x, pd_points[dim][row_idx, 1])
            if isinf(pd_points[dim][row_idx, 2])
                push!(y, pd_points[dim][row_idx, 1])
            else
                push!(y, pd_points[dim][row_idx, 2])
            end
        end
        if max_y < maximum(y)
            max_y = maximum(y)
        end
        if dim == 0
            scatter(copy(x), copy(y), label="Dim: "*string(dim))
        else
            scatter!(copy(x), copy(y), label="Dim: "*string(dim))
        end
    end
    plt = plot!([0, max_y], [0, max_y], label="", legend=:bottomright, aspect_ratio=:equal, xlims=(-0.1, max_y + 0.1), color=:red)
    savefig(plt, pdf_output_file)
end

C_tiny = eirene(M_tiny, model = "pc", maxdim=2)
tiny_pd_points = get_multidim_persistence_diagram(C_tiny)

C_medium = eirene(M_medium, model ="pc", maxdim=2)
medium_pd_points = get_multidim_persistence_diagram(C_medium)

C_large = eirene(M_large, model = "pc", maxdim=2)
large_pd_points = get_multidim_persistence_diagram(C_large)

plot_persistence_diagram(tiny_pd_points, "tiny_pd.pdf")

plot_persistence_diagram(medium_pd_points, "medium_pd.pdf")

plot_persistence_diagram(large_pd_points, "large_pd.pdf")
