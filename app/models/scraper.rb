class Scraper < Object
  
  require 'net/http'
  require 'uri'
   
  attr_accessor :search_urls, :clean_urls, :images, :titles, :descriptions
  
  MEN     = 0
  WOMEN   = 1
  BOTH    = 2
  MAIN_IMAGE_URL = "images.craigslist.org"
  
  def initialize(gender)
    cities = [
      "austin",
      "miami",
      "atlanta",
      "washingtondc"
      ]
      
    genders = {}
    genders[ "dudes" ] = "m4w" if (gender.eql?(MEN) or gender.eql?(BOTH))
    genders[ "babes" ] = "w4m" if (gender.eql?(WOMEN) or gender.eql?(BOTH))

    @search_urls  = []
    @clean_urls   = {}
    @images       = {}

    @titles        = {}
    @descriptions  = {}

    pics_directory = 'pics/'
    FileUtils.mkdir(pics_directory) unless File.exist?(pics_directory)

    genders.each do |file_name, url_name|
      
      gender_directory = 'pics/' + file_name
      FileUtils.mkdir(gender_directory) unless File.exist?(gender_directory)
      
      cities.each do |city_name|
        
        city_directory = 'pics/' + file_name + '/' + city_name
        FileUtils.mkdir(city_directory) unless File.exist?(city_directory)

        0.upto(4) do |nth_page|
          
          FileUtils.mkdir(city_directory + '/' + nth_page.to_s) unless File.exist?(city_directory + '/' + nth_page.to_s)
          
          name = "http://" + city_name + ".craigslist.org/search/" + url_name + "?query=&srchType=A&minAsk=&maxAsk=&hasPic=1&s=" + nth_page.to_s + "00"
          @search_urls  << name
          puts "searching " + name

          text = get_url(name)
          urls = parse_links(text).
            find_all { |url| url[0].include?(url_name) and url[0].include?("http") }.
            reject { |url| url[0].include?('search') }.
            collect { |array| array[0] }

          urls.each_with_index do |url, i|
            
            local_file_name = city_directory + '/' + nth_page.to_s + '/' + file_name.singularize + '_' + i.to_s
            local_image_name = local_file_name + '.jpg'
            local_text_name = local_file_name + '.txt'
            
            puts url.inspect
            content = get_url(url)
            # puts content.inspect

            # DOWNLOAD HEADLINE
            headline = " "
            unless parse_title(content).first.empty?
              unless parse_title(content).first.first.empty?
                headline = parse_title(content).first.first
                puts headline.inspect
              end
            end
            
            # DOWNLOAD DESCRIPTION
            description = parse_description(content)
            # puts description.inspect
            
            # DOWNLOAD IMAGE
            image_filename_array = parse_image_names( content )
            unless (image_filename_array.nil? or image_filename_array.empty?)
              unless (image_filename_array.first.nil? or image_filename_array.first.empty?)
              	puts "names " + image_filename_array.first.first.split('","').inspect
              	image_filename_array.first.first.split('","').each_with_index do |name, j|
              		puts "name " + name.to_s              	
	                download_image(name, local_file_name + "-" + j.to_s + ".jpg")
              	end
              end
            end
            
            # WRITE TEXT
            # write_text(local_text_name, headline + '\n' + description )
            # write_text(local_text_name, clean_text( headline + '\n' + description ) )
            write_text(local_text_name, encode_text( headline + '\n' + description ) )
          end
        end
      end
    end
    nil
  end
  
  def get_url(name)
    Net::HTTP.get(URI.parse(name))
  end

  def parse_links(content)
    content.scan(/href=\"(.*?)\"/)
  end

  def parse_image_names(content)
   # content.scan(/img src=\"(.*?)\"/)
   # content.scan(/http:\/\/images.craigslist.org\/(.*?)\.jpg\"/)
   content.scan(/imgList = new Array\(\"(.*?)\"\);/)
  end
  
  def parse_title(content)
    ret_val = content.scan(/h2\>(.*?)\<\/h2/)
  end

  def parse_description(content)
    i_1 = content.index("userbody")
    i_2 = content.index("START CLTAGS")
    ret_val = (
      (i_1.nil? or i_2.nil?) ? content : 
      content[ content.index("userbody") + 11 .. content.index("START CLTAGS") - 11 ]
    )
  end

  def download_image(image_filename, local_image_name)
  	puts "image_filename " + URI.parse(image_filename).to_s
    open(local_image_name, "wb") { |file| file.write( Net::HTTP.get( URI.parse(image_filename) ) ) }
  end
  
  def write_text(file_name, text)
    File.open(file_name, 'w') {|f| f.write( text ) }
  end

  def encode_text(text)
    # text.force_encoding("ASCII-8BIT")
    text.force_encoding('UTF-8')
  end
  
  def clean_text(text)
    text.gsub!(/[^\x20-\x7e]/,'')
  end
   
end