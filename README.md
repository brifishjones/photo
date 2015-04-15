# photo
photo.rb is great for assembling images from different sources (e.g. camera, phone, tablet) and combining them into an chronologically ordered library with a common naming sequence.

Script will sort images a given directory by date and rename them according to a 4 digit year followed by a delimeter and in sequence starting with the variable 'start_value'. Zeros will be padded in front of numbers depending on the precision specified.

To execute: ruby photo.rb
and pass in 'directory', 'year', 'start_value', 'precision', and 'delimeter' as arguments (e.g. ruby photo.rb pictures/family 2014 750 5, -).
  
The sequence of renamed files in chronological order will be:
2014-00750.jpg, 2014-00751.jpg, 2014-00752.jpg, ...
and can be found in a directory with the same name with "_chrono" appended
(e.g. pictures/family_chrono)
 
With no arguments (e.g. ruby photo.rb) the directory defaults to the same directory
as photo.rb, year defaults to the current year, start_value = 1, precision = 4,
and delimeter = '.'.
2015.0001.jpg, 2015.0002.jpg, 2015.0003.jpg, ...

Note that delimeters can only be . - or _
