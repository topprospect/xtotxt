require 'yaml'

class XtotxtError < StandardError; end

class Xtotxt
  VERSION = 0.6
  SUPPORTED_EXTENSIONS = %w{txt pdf doc docx odt rtf html}

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

  def convert(input_file_name,tmp_dir = "/tmp",retain_output=false)
    dot_ext = File.extname(input_file_name)
    file_ext = dot_ext.slice(1,dot_ext.length)
    raise XtotxtError.new("not a supported document extension: #{file_ext}") unless SUPPORTED_EXTENSIONS.member?(file_ext)

    file_base = File.basename(input_file_name, file_ext)

    output_file_name = "#{tmp_dir}/#{file_base}txt"

    command_line = case file_ext
    when "txt"
        "cp -p #{input_file_name}                  #{output_file_name}"
    when "pdf"
        "#{@ext[:pdf]} #{input_file_name} -      > #{output_file_name}"
    when "doc"
        "#{@ext[:doc]} #{input_file_name}        > #{output_file_name}"
    when "docx"
        "#{@ext[:docx]} #{input_file_name}         #{output_file_name}"
    when "odt":
        "#{@ext[:odt]} #{input_file_name} --output=#{output_file_name}"
    when "rtf":
        "#{@ext[:rtf]} --text #{input_file_name} > #{output_file_name}"
    when "html":
        "#{@ext[:html]} -o #{output_file_name} #{input_file_name}"
    else
        raise XtotxtError.new("have no way to convert #{file_ext} yet")
    end

    #puts "executing: #{command_line}"

    command_output = `#{command_line} 2>/dev/null` if command_line and not command_line.empty?
    text = if $? == 0
      File.read(output_file_name)
    else
      raise XtotxtError.new("Failed to convert #{input_file_name}. Exit status: #{$?.exitstatus}.  Output: #{command_output}")
    end

    File.delete(output_file_name) unless retain_output

    case file_ext
      when "rtf"
        skip_unrtf_header(text)
      else
        text
    end
  end

  def initialize(ext=nil)
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