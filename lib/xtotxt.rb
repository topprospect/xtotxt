class Xtotxt

  @@pdf2txt = "xpdf-pdftotxt"

  def convert(input_file_name)
    path_list = input_file_name.split(".")

    ext = path_list.pop
    puts "I got #{input_file_name} of type #{ext}"


    raise("not a supported document extension: #{ext}") unless %w{pdf doc docx}.member?(ext)

    output_file = (path_list << "txt").join(".")

    command_line = case ext
    when "pdf"
        "#{@@pdf2txt} #{input_file_name}"
    else
        raise "have no way to convert #{ext} yet"
    end

    puts "executing: #{command_line}"
    command_output = `command_line`
    text = if $? == 0
      File.read(output_file)
    else
      raise "Failed to convert #{input_file_name}. Exit status: #{$?.exitstatus}.  Output: #{command_output}"
    end
    puts "the text is: #{text}"
    text
  end

  puts "xtotxt is included"
end