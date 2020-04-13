using Buffers
using Zygote
using Test

@testset "Buffer" begin
  @test gradient([1, 2, 3]) do x
    b = Buffer(x)
    b[:] = x
    return sum(copy(b))
  end == ([1,1,1],)

  function vstack(xs)
    buf = Buffer(xs, length(xs), 5)
    for i = 1:5
      buf[:, i] = xs
    end
    return copy(buf)
  end

  @test gradient(x -> sum(vstack(x)), [1, 2, 3]) == ([5, 5, 5],)

  buf = Buffer([1, 2, 3])
  buf[1] = 1
  copy(buf)
  @test_throws ErrorException buf[1] = 1
  @test eltype(buf) === Int
  @test length(buf) === 3
  @test ndims(buf) === 1
  @test size(buf) === (3, )
  @test size(buf, 2) === 1
  @test axes(buf) == (1:3, )
  @test axes(buf, 2) == 1:1
  @test eachindex(buf) == 1:3
  @test stride(buf, 2) === 3
  @test strides(buf) === (1, )
  @test collect(buf) == collect(copy(buf))

  @test gradient([1, 2, 3]) do xs
    b = Buffer(xs)
    b .= xs .* 2
    return sum(copy(b))
  end == ([2,2,2],)

  @test gradient(2) do x
    b = Zygote.Buffer([])
    push!(b, x)
    push!(b, 3)
    prod(copy(b))
  end == (3,)
end
