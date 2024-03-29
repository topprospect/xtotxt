require 'yaml'

class XtotxtError < StandardError; end

class Xtotxt
  VERSION = 0.8
  SUPPORTED_EXTENSIONS = %w{txt pdf doc docx odt rtf html}
  TMP_DIR = "/tmp"

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

  def convert_file(input_file_name, tmp_dir = TMP_DIR)
    dot_ext  = File.extname(input_file_name)
    file_ext = dot_ext.slice(1,dot_ext.length)
    raise XtotxtError.new("not a supported document extension: #{file_ext}") unless SUPPORTED_EXTENSIONS.member?(file_ext)

    file_base = File.basename(input_file_name, dot_ext)

    output_file_name = "#{tmp_dir}/#{file_base}.txt"

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
        # NB:
        "#{@ext[:html]} -o #{output_file_name} #{input_file_name}"
    else
        raise XtotxtError.new("have no way to convert #{file_ext} yet")
    end

    #puts "executing: #{command_line}"

    command_output = `#{command_line} 2>/dev/null` if command_line and not command_line.empty?
    if $? == 0 && File.exists?(output_file_name)
      File.new(output_file_name,"r")
    else
      raise XtotxtError.new("Failed to convert #{input_file_name}. Exit status: #{$?.exitstatus}.  Output: #{command_output}")
    end
  end


  def convert(input_file_name,tmp_dir = TMP_DIR,retain_output=false)

    file = convert_file(input_file_name, tmp_dir)
    text = file.read
    file.close
    File.delete(file.path) unless retain_output

    case File.extname(input_file_name)
    when ".rtf"
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
    while a.shift != "-----------------\n"
    end
    a.join
  end

end