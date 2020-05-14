using Buffers
using Test
using Zygote

@testset "Buffers" begin
    @testset "basic" begin
        w = rand(2, 3)
        b = rand(2)
        c = rand(2)

        buff = Buffer([])
        @test length(buff) == 0

        push!(buff, w)
        push!(buff, b)
        push!(buff, c)
        @test length(buff) == 3
        @test buff[1] === w
        @test buff[2] === b
        @test buff[3] === c

        deleteat!(buff, 2)
        @test length(buff) == 2
        @test buff[1] === w
        @test buff[2] === c

        deleteat!(buff, 1)
        @test length(buff) == 1
        @test buff[1] === c
    end

    @testset "gradcheck" begin
        @test gradient([1, 2, 3]) do x
            b = Buffer(x)
            b[:] = x
            return sum(copy(b))
        end == ([1, 1, 1],)

        function vstack(xs)
            buf = Buffer(xs, length(xs), 5)
            for i = 1:5
                buf[:, i] = xs
            end
            return copy(buf)
        end

        function _scaledpairedcumsum(xs)
            n = length(xs)
            n > 0 || return copy(xs)
            buf = Buffer(xs)
            buf[1:2] = xs[1:2]
            for i in 3:2:(n - 1)
                buf[i:(i + 1)] = buf[(i - 2):(i - 1)] + i * xs[i:(i + 1)]
            end
            return copy(buf)
        end

        @test gradient(x -> sum(vstack(x)), [1, 2, 3]) == ([5, 5, 5],)

        @test Zygote.pullback(_scaledpairedcumsum, 1:4)[2]([0, 0, 0, 1]) == ([0, 1, 0, 3],)
        @test Zygote.pullback(_scaledpairedcumsum, 1:4)[2]([0, 0, 1, 0]) == ([1, 0, 3, 0],)
        @test Zygote.pullback(_scaledpairedcumsum, 1:4)[2]([1, 1, 1, 1]) == ([2, 2, 3, 3],)

        buf = Buffer([1, 2, 3])
        buf[1] = 1
        copy(buf)
        @test_throws ErrorException buf[1] = 1
        @test eltype(buf) === Int
        @test length(buf) === 3
        @test ndims(buf) === 1
        @test size(buf) === (3,)
        @test size(buf, 2) === 1
        @test axes(buf) == (1:3,)
        @test axes(buf, 2) == 1:1
        @test eachindex(buf) == 1:3
        @test stride(buf, 2) === 3
        @test strides(buf) === (1,)
        @test collect(buf) == collect(copy(buf))
        @test Base.IteratorSize(buf) == Base.IteratorSize([1, 2, 3])

        @test gradient([1, 2, 3]) do xs
            b = Buffer(xs)
            b .= xs .* 2
            return sum(copy(b))
        end == ([2, 2, 2],)

        @test gradient(2) do x
            b = Buffer([])
            push!(b, x)
            push!(b, 3)
            prod(copy(b))
        end == (3,)
    end

    VERSION > v"1.3-" && include("threads.jl")
end
