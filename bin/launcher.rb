# RepoToolKit last update 2018-10-13
Dir['../lib/*.rb'].each { |f| require_relative f }

# Setting $debug to TRUE will cause additional debug lines to print, helping localize bugs
$debug = FALSE
if $debug == TRUE then puts "*** debug line: #{__FILE__}:#{__LINE__} ***" end

# Superclass
class TuftsScholarship
  include SetDirectories
  include CleanFileNames
  include CreateSubdirectories
  include CollectionXML
  include Transforms
  include PackageBinaries
  include CleanUpXML
  include QA
end

# Excel ingest processes
class ExcelBasedIngest < TuftsScholarship
  include ToRoo
  def extract
    clean.excel_subfolders.roo_to_xml
  end

  def finish
    package.postprocess_excel_xml.close_directories.qa_it
  end
end
# Specific ingest issues for Springer
class SpringerIngest < TuftsScholarship
  include UnzipIt
  def extract
    springer_subfolders.unzip
  end

  def transform_it
    preprocess_springer_xml.collection.transform_it_springer
  end

  def finish
    package.postprocess_springer_xml.close_directories.qa_it
  end
end
# Specific ingest issues for Proquest
class ProquestIngest < TuftsScholarship
  include UnzipIt

  def extract
    proquest_subfolders.unzip
  end

  def transform_it
    collection.transform_it_proquest
  end

  def finish
    package.postprocess_proquest_xml.close_directories.qa_it
  end
end
# Specific ingest issues for MARC xml
class InHouseIngest < TuftsScholarship
  include Rename

  def extract
    inhouse_subfolders
  end

  def transform
    rename_mrc_xml.transform_it_inhouse.rename_xml_to_original
  end

  def finish
    package.postprocess_alma_xml.close_directories.qa_it
  end
end
# Create a list of subjects used by catalogers
class SubjectAnalysis < TuftsScholarship
  include AnalyzeIt
end
# Specific ingest issues for MARC xml
class LicensedVideoIngest < TuftsScholarship
  include Rename

  def extract
    inhouse_subfolders
  end

  def transform
    rename_mrc_xml.transform_it_licensed_video.rename_xml_to_original
  end

  def finish
    package.postprocess_alma_xml.close_directories.qa_it
  end
end
# Specific ingest issues for MARC xml
class LicensedPDFIngest < TuftsScholarship
  include Rename

  def extract
    inhouse_subfolders
  end

  def transform
    rename_mrc_xml.transform_it_licensed_pdf.rename_xml_to_original
  end

  def finish
    package.postprocess_alma_xml.close_directories.qa_it
  end
end


$is_windows = (RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/)
$prompt = '> '
$saxon_path = ENV['SAXON_PATH']
$xslt_path = File.expand_path('../xslt', File.dirname(__FILE__))

if !$saxon_path then
  puts
  puts 'The environment variable SAXON_PATH is missing or blank.'
  puts 'SAXON_PATH must contain the full pathname to the saxon jar file.'
  puts 'Goodbye.'
  sleep(3)
  exit
end

if $is_windows then
  system ("cls")
else
  system ("clear")
end

if $debug == TRUE then puts "*** debug line: #{__FILE__}:#{__LINE__} ***" end
puts '***************************************************'
puts
puts 'Welcome to the Repository Toolkit for MIRA 2.0!'
puts
puts 'What would you like to process?'
puts
puts '1. Faculty Scholarship.'
puts '2. Student Scholarship.'
puts '3. Nutrition School.'
puts '4. Art and Art History (Trove).'
puts '5. Springer Open Access Articles.'
puts '6. Proquest Electronic Disertations and Theses.'
puts '7. In-House digitized books.'
puts '8. Subject Analysis.'
puts '9. SMFA Artist Books.'
puts '10. Licensed Streaming Video.'
puts '11. Licensed PDF.'
puts '12. Exit.'
puts '13. Test XML.'
puts

print $prompt
# Loop
while input = gets.chomp.strip
  if $debug == TRUE then puts "*** debug line: #{__FILE__}:#{__LINE__} ***" end
  case input
    when '13', '13.', 'test'
    puts
    puts 'Launching the Test XML script.'
    a_test_xml = TestXML.new
    a_test_xml.testit
    break

  when '1', '1.', 'Faculty'
    puts
    puts 'Launching the Faculty Scholarship script.'
    a_new_faculty_ingest = ExcelBasedIngest.new
    a_new_faculty_ingest.extract.faculty.excel.collection.transform.finish
    break

  when '2', '2.', 'Student'
    puts
    puts 'Launching the Student Scholarship script.'
    a_new_student_ingest = ExcelBasedIngest.new
    a_new_student_ingest.extract.student.excel.collection.transform.finish
    break

  when '3', '3.', 'Nutrition'
    puts
    puts 'Launching the Nutrtion Scholarship script.'
    a_new_nutrition_ingest = ExcelBasedIngest.new
    a_new_nutrition_ingest.extract.nutrition.excel.collection.transform.finish
    break

  when '4', '4.', 'Trove'
    puts
    puts 'Launching the Trove script.'
    a_new_trove_ingest = ExcelBasedIngest.new
    a_new_trove_ingest.extract.trove.excel.collection.transform.finish
    break

  when '5', '5.', 'Springer'
    puts
    puts 'Launching the Springer script.'
    a_new_springer_ingest = SpringerIngest.new
    a_new_springer_ingest.extract.transform_it.finish
    break

  when '6', '6.', 'Proquest'
    puts
    puts 'Launching the Proquest script.'
    a_new_proquest_ingest = ProquestIngest.new
    a_new_proquest_ingest.extract.transform_it.finish
    break

  when '7', '7.', 'inHouse'
    puts
    puts 'Launching the in-house script.'
    a_new_inhouse_ingest = InHouseIngest.new
    a_new_inhouse_ingest.extract.transform.finish
    break

  when '8', '8.', 'Subject'
    puts
    puts 'Launching the Subject Analysis script'
    a_new_analysis = SubjectAnalysis.new
    a_new_analysis.subject_only.close_directories.re_qa_subject
    break

  when '9', '9.', 'SMFA'
    puts
    puts 'Launching the SMFA artist books script.'
    a_new_smfa_ingest = ExcelBasedIngest.new
    a_new_smfa_ingest.extract.smfa.excel.collection.transform.finish
    break

  when '10', '10.', 'Video'
    puts
    puts 'Launching the Licensed Streaming Video script.'
    a_new_licensed_video_ingest = LicensedVideoIngest.new
    a_new_licensed_video_ingest.extract.transform.finish
    break

  when '11', '11.', 'PDF'
    puts
    puts 'Launching the Licensed PDF script.'
    a_new_licensed_pdf_ingest = LicensedPDFIngest.new
    a_new_licensed_pdf_ingest.extract.transform.finish
    break

  when '12', '12.', '12. Exit', 'Exit', 'exit'
    puts
    puts 'Goodbye.'
    break

  else
    puts 'Please select from the above options.'
    print $prompt
  end
end
sleep(3)
