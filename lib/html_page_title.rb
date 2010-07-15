require 'redirect_follower'
require 'hpricot'
def HtmlPageTitle(url)
  HtmlPageTitle.new(url)
rescue SocketError => err
  nil
end

#
# A simple class for finding the title of a given http url by fetching the
# given url, following all eventual redirects and finally parsing it through
# hpricot.
# 
# You can either use the shorthand form or initialize the instance properly:
#  * HtmlPageTitle('http://github.com')
#  * HtmlPageTitle.new('http://github.com')
# 
# Those calls are equivalent, except for one subtle difference:
# The shorthand form will swallow SocketErrors and return nil (i.e. this will
# happen for invalid urls), while the regular instantiation via new will 
# throw that error.
# 
# You can either get the title, the heading (which will be the content of the
# first h1 tag in the body) or the label, which will be (in the following order 
# by availability) either the heading, or the title, or the target url after
# redirecting. 
# Note that if the title or the heading can not be found (e.g. a non-HTML
# document), both methods will return nil, so the label method is the only one
# that will always return some kind of string
#
class HtmlPageTitle
  attr_reader :original_url
  def initialize(original_url)
    @original_url = original_url
    title # retrieve data so exceptions can be thrown
  end
  
  def document
    @document ||= Hpricot(redirect.body)
  end
  
  def title
    return @title if @title
    if title_tag = document.at('head title')
      @title = title_tag.inner_html.strip.chomp
    end
  end
  
  # Retrieves the first h1 tag in the page and returns it's content
  def heading
    return @heading if @heading
    if heading_tag = document.at('body h1')
      @heading = heading_tag.inner_html.strip.chomp
    end
  end
  
  # Returns either the heading, or the title, or the url in this order
  # by availability
  def label
    heading or title or url
  end

  # Returns the redirect follower instance used for resolving
  # this instances url
  def redirect
    @redirect = RedirectFollower.new(original_url)    
  end
  
  # Returns the target url after all redirects
  def url
    redirect.url
  end
  
  # Returns the body of the document at the (redirected?) target
  def body
    redirect.body
  end
end