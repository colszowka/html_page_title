require 'helper'

class TestHtmlPageTitle < Test::Unit::TestCase
  def test_quick_access
    instance = HtmlPageTitle('http://www.spiegel.de')
    assert_equal "SPIEGEL ONLINE - Nachrichten", instance.title
    assert_equal 'http://www.spiegel.de', instance.url
    assert_equal 'SPIEGEL ONLINE', instance.heading
    assert_equal instance.heading, instance.label
  end
  
  def test_access_with_instantiation
    instance = HtmlPageTitle.new('http://www.spiegel.de')
    assert_equal "SPIEGEL ONLINE - Nachrichten", instance.title
    assert_equal 'http://www.spiegel.de', instance.url
    assert_equal 'SPIEGEL ONLINE', instance.heading
    assert_equal instance.heading, instance.label

    assert instance.body.kind_of?(String)
    assert_equal instance.redirect.url, instance.url
    assert_equal RedirectFollower, instance.redirect.class
    assert_equal Hpricot::Doc, instance.document.class
  end
  
  def test_with_redirect
    instance = HtmlPageTitle.new('http://is.gd/bNZYZ')
    assert_equal "TASCHEN Books: Byrne, Six Books of Euclid", instance.title
    assert_equal 'http://www.taschen.com/pages/en/catalogue/classics/all/06724/facts.byrne_six_books_of_euclid.htm', instance.url
    assert_equal 'Byrne, Six Books of Euclid', instance.heading
    assert_equal instance.heading, instance.label

    assert instance.body.kind_of?(String)
    assert_equal instance.redirect.url, instance.url
    assert_equal RedirectFollower, instance.redirect.class
    assert_equal Hpricot::Doc, instance.document.class
  end
  
  def test_quick_access_with_invalid_urls
    assert_nil HtmlPageTitle('http://www.thisdoesnotexistforrealsure.de')
    assert_nil HtmlPageTitle('http://www.notldisntniceeh')
  end
  
  def test_regular_access_with_invalid_urls
    assert_raise SocketError do 
      HtmlPageTitle.new('http://www.thisdoesnotexistforsure.de')
    end
    assert_raise SocketError do
      HtmlPageTitle.new('http://www.thisdoesnotexistforsur')
    end
  end
  
  def test_non_html_url
    instance = HtmlPageTitle.new('http://gist.github.com/raw/93965/64e0b8445d0c3481f755fe65fd79297fcf6da909/x')
    assert_nil instance.title
    assert_nil instance.heading
    assert_equal 'http://gist.github.com/raw/93965/64e0b8445d0c3481f755fe65fd79297fcf6da909/x', instance.label
  end
  
  def test_url_without_h1
    instance = HtmlPageTitle('http://gembundler.com/v1.0/index.html')
    assert_equal instance.title, instance.label
  end
end
