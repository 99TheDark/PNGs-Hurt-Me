struct Color
    r::UInt8
    g::UInt8
    b::UInt8
end

function openbinary(loc::String)
    path = "$(@__DIR__)/$loc"

    size = filesize(path)
    data = Array{UInt8}(zeros(size))
    read!(path, data)

    return [data, size]
end

function assemblebytes(bytes::Array{UInt8})
    len = length(bytes)
    val = 0
    for i in range(1, len)
        val += bytes[i] << (len - i)
    end
    return val
end

function bytestring(bytes::Array{UInt8})
    str = ""
    for b in bytes str *= Char(b) end
    return str
end

function readpng(loc)
    bin = openbinary(loc)

    data, size = bin

    header = Array{UInt8}([137, 80, 78, 71, 13, 10, 26, 10])

    # Check first 8 bytes
    if data[1:8] == header
        width = 0
        height = 0
        palette::Array{Color} = []

        idx = 9
        println(data)
        while idx <= size
            len = assemblebytes(data[idx:(idx+=4)-1])
            type = bytestring(data[idx:(idx+=4)-1])
            chunk = data[idx:(idx+=len)-1]
            idx += 4

            # Why no switch-case-break :(
            if type == "IHDR" # len = 13
                width = assemblebytes(chunk[1:4])
                height = assemblebytes(chunk[5:8])
                # depth
                # color type 
                # compression 
                # filter 
                # interlace
            elseif type == "sRGB" 
                # intent 
            elseif type == "pHYs"
                # pixels per unit x
                # pixels per unit y
                # unit type
            elseif type == "PLTE"
                for i in 1:3:len
                    push!(palette, Color(chunk[i], chunk[i + 1], chunk[i + 2]))
                end
            elseif type == "IDAT"
                str = "["
                for col in chunk
                    c = palette[col % length(palette) + 1]
                    str *= "color($(c.r), $(c.g), $(c.b)), "
                end
                str = chop(str, tail = 2)
                str *= "]"
                println(str)
            elseif type == "IEND"
                break
            end
        end
    else
        println("Not a PNG.")
    end
end

readpng("images/grass.png")