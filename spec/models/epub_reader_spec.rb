require 'spec_helper'

describe EpubReader do
  
  it "Reads in pg58.epub and produces the correct output array" do
    reader = EpubReader.new('public/gutenberg/pg58.epub')
    correct_answer = ["  THE FIRST BOOK",
                      "\n\n",
                      "I, WHO erewhile the happy Garden sung\n\n  By one man's disobedience lost, now sing\n\n  Recovered Paradise to all mankind,\n\n  By one man's firm obedience fully tried\n\n  Through all temptation, and the Tempter foiled\n\n  In all his wiles, defeated and repulsed,\n\n  And Eden raised in the waste Wilderness."]

    expect(reader.text_array).to eq(correct_answer)
  end

  it "Reads in pg66.epub and produces the correct output array" do
    reader = EpubReader.new('public/gutenberg/pg66.epub')
    correct_answer = ["                            CHAPTER ONE",
                       "\n\n",
                       "                 THE DEVELOPMENT OF ELECTRICITY",
                       "\n\n",
                       "The phenomenon which Thales had observed and recorded five\ncenturies before the birth of Christ aroused the interest of many\nscientists through the ages."]

    expect(reader.text_array).to eq(correct_answer)
  end

    it "Reads in pg67.epub and produces the correct output array" do
    reader = EpubReader.new('public/gutenberg/pg67.epub')
    correct_answer = ["CHAPTER 1",
                     "\n",
                     "African Origins",
                     "\n",
                     "",
                     "\n",
                     "The Human Cradle",
                     "\n",
                     "THREE and a half centuries of immigration have injected ever-fresh doses of energy and tension into the American bloodstream."]

    expect(reader.text_array).to eq(correct_answer)
  end

  it "Reads in pg19.epub and raises an error b/c it can't find the starting chapter" do

    expect{ EpubReader.new('public/gutenberg/pg19.epub') }.to raise_error
  end

end
