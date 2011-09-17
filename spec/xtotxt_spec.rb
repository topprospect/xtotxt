require 'spec_helper'
require 'xtotxt'

describe Xtotxt do
  before do
    @x = Xtotxt.new
    @input = "pdftext.pdf"
  end

  describe "convert" do
    context "input parameters and results" do

      # TODO make pending
      #it "recognizes our supported documents formats" do
      #  %w{pdf doc docx}.each do |ext|
      #    lambda { @x.convert("pdftext."+ext) }.should_not raise_error
      #  end
      #end

      it "accepts one input file argument (of the right type)" do
         #lambda { @x.convert("pdftext.pdf") }.should_not raise_error
        @x.convert("pdftext.pdf")
      end

      it "needs the input file argument" do
         lambda { @x.convert() }.should raise_error
      end

      it "does not accept more than one file argument" do
         lambda { @x.convert("a","b") }.should raise_error
      end

      it "does not accept one input file argument of the wrong type" do
         lambda { @x.convert("test.bat") }.should raise_error
      end

      it "returns a string" do
        text = @x.convert("pdftext.pdf")
        text.class.should == String
      end

    end
  end

  it "converts a pdf document" do
    text = @x.convert("pdftext.pdf")

    text.should_not be_empty
  end

end