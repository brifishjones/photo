# photo.rb is great for assembling images from different sources (e.g. camera,
# phone, tablet) and combining them into an chronologically ordered library with a 
# common naming sequence.
#
# Script will sort images a given directory by date and rename them according to a 4 digit
# year followed by a delimeter and in sequence starting with the variable 'start_value'.
# Zeros will be padded in front of numbers depending on the precision specified.
#
# To execute: ruby photo.rb
# and pass in 'directory', 'year', 'start_value', 'precision', and 'delimeter'
# as arguments (e.g. ruby photo.rb pictures/family 2014 750 5, -).
# 
# The sequence of renamed files in chronological order will be:
# 2014-00750.jpg, 2014-00751.jpg, 2014-00752.jpg, ...
# and can be found in a directory with the same name with "_chrono" appended
# (e.g. pictures/family_chrono)
#
# With no arguments (e.g. ruby photo.rb) the directory defaults to the same directory
# as photo.rb, year defaults to the current year, start_value = 1, precision = 4,
# and delimeter = '.'.
# 2015.0001.jpg, 2015.0002.jpg, 2015.0003.jpg, ...
#
# Note that delimeters can only be . - or _

require "FileUtils.rb"

class Photo
  attr_accessor :has_datetime, :datetime, :timestamp
  EXIF_datetime_regexp = /(\d{4}):(\d{2}):(\d{2})\s(\d{2}):(\d{2}):(\d{2})/

  # constructor: grab exif date, month
  def initialize(filename)
    fp = File.open(filename, "rb").each_line do |line|
      dt = line.match(EXIF_datetime_regexp)
      if dt
        self.has_datetime = true
        self.datetime  = dt[1] + dt[2] + dt[3] + dt[4] + dt[5] + dt[6] + '.jpg'
			  self.timestamp = Time.local(dt[1], dt[2], dt[3], dt[4], dt[5], dt[6])
      end
    end
    fp.close
  end
end

class PhotoCollection
  attr_accessor :directory, :year, :start_value, :precision, :delimeter 

  def initialize args
		@pwd = FileUtils.pwd 
    @directory = args.length < 1 ? '.' : args[0].sub(/(\/)+$/, '')
    @chrono_directory = args.length < 1 ? 'chrono' : @directory + "_chrono"
    @year = args.length < 2 ? Time.now.year : args[1].to_i
    @start_value = args.length < 3 ? 1 : args[2].to_i
    @precision = args.length < 4 ? 4 : args[3].to_i
    @delimeter = args.length < 5 || (args[4] != '-' && args[4] != '_') ? '.' : args[4]
		directory_text = @directory == '.' ? "the current directory" : @directory

    Dir.chdir(@directory)
    files = Dir.glob("*.[Jj][Pp][Gg]")

    puts ''
    puts files.length.to_s + ' jpg files in ' + directory_text + ' will be ordered by date'
    puts 'starting with ' + @year.to_s + @delimeter + @start_value.to_s.rjust(@precision, "0") + '.jpg' 
    puts ''
    puts 'Any files without a datetime stamp will be ordered alphabetically.'
    puts ''
    puts 'Enter y to continue or n to abort.'
    ARGV.clear
    cont = gets.chomp
    exit if cont != 'y'
    if File.directory?(@pwd + "/" + @chrono_directory)
			FileUtils.rm_r(@pwd + "/" + @chrono_directory)
    end
		FileUtils.mkdir(@pwd + "/" + @chrono_directory)
		Dir.chdir(@pwd)
  end

  def order_by_date
  # copy files to @chrono_directory and rename according to image timestamp
		puts ''
		puts 'Files being renamed according to image timestamp...'

    Dir.chdir(@directory)
    files = Dir.glob("*.[Jj][Pp][Gg]")
		FileUtils.cp(files, @pwd + "/" + @chrono_directory)

    Dir.chdir(@pwd + "/" + @chrono_directory)
    files = Dir.glob("*.[Jj][Pp][Gg]")
    # Order files by date
    for file in files
      photo = Photo.new(file)
      if photo.has_datetime
        puts photo.datetime
        File.rename(file, photo.datetime)
      else
        File.rename(file, "x_" + file)
        puts file + " does not have a datetime stamp and will be ordered alphabetically."
      end
    end
		Dir.chdir(@pwd)
  end

  def rename_files
    # Rename ordered files using year.photo.jpg naming convention
		puts ''
    puts 'Files being renamed chronologically using year' + @delimeter + 'photo.jpg naming convention...'

    Dir.chdir(@pwd + "/" + @chrono_directory)
    files = Dir.glob("*.jpg")

    start = @start_value
    for file in files
      photo = Photo.new(file)
      newname = @year.to_s + @delimeter + start.to_s.rjust(precision, "0") + ".jpg"
      puts newname
      File.rename(file, newname)
			
			# change the file access and modification times to match the image timestamp
      File.utime(photo.timestamp, photo.timestamp, newname) if photo.has_datetime 

      start += 1
    end

    puts ''
		puts 'Files have been chronologically ordered and can be found in the directory:'
		puts @pwd + '/' + @chrono_directory
		puts ''
		Dir.chdir(@pwd)
  end
end


# Main
photoCollection = PhotoCollection.new(ARGV)
photoCollection.order_by_date
photoCollection.rename_files

