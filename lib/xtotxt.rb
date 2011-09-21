require 'yaml'

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
  end

  def convert(input_file_name)
    path_list = input_file_name.split(".")

    ext = path_list.pop

    raise("not a supported document extension: #{ext}") unless %w{pdf doc docx}.member?(ext)

    output_file = (path_list << "txt").join(".")

    command_line = case ext
    when "pdf"
        "#{@ext[:pdf]} #{input_file_name}"
    when "doc"
        "#{@ext[:doc]} > #{output_file} #{input_file_name}"
    when "docx"
        "#{@ext[:docx]} #{input_file_name}"
    else
        raise "have no way to convert #{ext} yet"
    end

    command_output = `#{command_line}`
    text = if $? == 0
      File.read(output_file)
    else
      raise "Failed to convert #{input_file_name}. Exit status: #{$?.exitstatus}.  Output: #{command_output}"
    end
    text
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

    puts "@ext: #{@ext}, @@ext: #{@@ext}"
  end

end