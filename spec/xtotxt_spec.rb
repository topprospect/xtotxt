require 'spec_helper'
require 'xtotxt'

describe Xtotxt do
  before do
    @ext = { :pdf  => "/opt/local/bin/xpdf-pdftotext",
             :doc  => "/opt/local/bin/antiword",
             :docx => "/usr/local/bin/docx2txt.pl" }

    @x = Xtotxt.new(@ext)
    @input = "test.pdf"
  end

  describe "convert" do

    it "is created with a single hash argument containing convertors" do
      lambda { Xtoxt.new }.should raise_error

      lambda { Xtoxt.new(1, 2) }.should raise_error
    end

    context "input parameters and results" do

      # TODO make pending
      #it "recognizes our supported documents formats" do
      #  %w{pdf doc docx}.each do |ext|
      #    lambda { @x.convert("pdftext."+ext) }.should_not raise_error
      #  end
      #end

      it "accepts one input file argument (of the right type)" do
         #lambda { @x.convert("test.pdf") }.should_not raise_error
        @x.convert("test.pdf")
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
        text = @x.convert("test.pdf")
        text.class.should == String
      end

    end
  end

  it "converts a pdf document correctly" do
    text = @x.convert("test.pdf")

    text.should == "three pigheaded piglets had a plan\n\n\f"
  end

  it "converts a doc document correctly" do
    text = @x.convert("test.doc")

    text.should == "\nthree pigheaded piglets had a plan\n\n"
  end

  it "converts a docx document correctly" do
    text = @x.convert("test.docx")

    text.should == "three pigheaded piglets had a plan\n\n"
  end

end