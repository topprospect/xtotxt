require 'yaml'

class XtotxtError < StandardError; end

class Xtotxt
  @@config_file_name = "xtotxt.yml"
  @@dirs_to_check    = %w{. ~ /etc}
  @@ext              = nil

  def self.read_config
    @@dirs_to_check.each do |dir|
      ["","."].each do |prefix|
        file_name = "#{dir}/#{prefix}#{@@config_file_name}"
        if File.exists?(file_name)
          @@ext = YAML.load_file(file_name)
          return
        end
      end
    end
    @@ext = @ext_default
  end

  def convert(input_file_name)
    path_list = input_file_name.split(".")

    ext = path_list.pop

    raise XtotxtError.new("not a supported document extension: #{ext}") unless %w{pdf doc docx odt rtf html}.member?(ext)

    output_file = (path_list << "txt").join(".")

    command_line = case ext
    when "pdf"
        "#{@ext[:pdf]} #{input_file_name}"
    when "doc"
        "#{@ext[:doc]} > #{output_file} #{input_file_name}"
    when "docx"
        "#{@ext[:docx]} #{input_file_name}"
    when "odt":
        "#{@ext[:odt]} #{input_file_name} --output=#{output_file}"
    when "rtf":
        "#{@ext[:rtf]} --text #{input_file_name} > #{output_file}"
    when "html":
        "#{@ext[:html]} -o #{output_file} #{input_file_name}"
    else
        raise XtotxtError.new("have no way to convert #{ext} yet")
    end

    #puts "executing: #{command_line}"

    command_output = `#{command_line} 2>/dev/null`
    text = if $? == 0
      File.read(output_file)
    else
      raise XtotxtError.new("Failed to convert #{input_file_name}. Exit status: #{$?.exitstatus}.  Output: #{command_output}")
    end

    case ext
      when "rtf"
        skip_unrtf_header(text)
      else
        text
    end
  end

  def initialize(ext=nil)
    @version = Xtotxt::VERSION

    @ext =
      case
      when ext
        ext
      when @@ext
        @@ext
      else
        Xtotxt.read_config
        @@ext
      end
  end

  private

  def skip_unrtf_header(text)
    a = text.lines.to_a
    while true
      unless a.shift =~ /^###/
        unless a.shift == "-----------------\n"
          raise "cannot parse rtf"
        end
        break
      end
    end
    a.join
  end

end