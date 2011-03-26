# encoding: utf-8
require 'spec_helper'
require File.dirname(__FILE__) + '/shared_data_store_examples'
require 'mongo'

describe Dragonfly::DataStorage::MongoDataStore do
  
  before(:each) do
    begin
      Mongo::Connection.new
    rescue Mongo::ConnectionFailure => e
      pending "You need to start mongo on localhost:27017 to test the MongoDataStore"
    end
    @data_store = Dragonfly::DataStorage::MongoDataStore.new :database => 'dragonfly_test'
  end
  
  it_should_behave_like 'data_store'
  
  describe "destroying" do

    it "should raise an error if the data doesn't exist" do
      lambda{
        @data_store.destroy('1a1a1a1a1a1a1a1a')
      }.should raise_error(Dragonfly::DataStorage::DataNotFound)
    end
    
  end
  
  describe "authenticating" do
    before(:each) do
      @temp_object = Dragonfly::TempObject.new('Feijão verde')
    end
    
    it "should not attempt to authenticate if a username is not given" do
      @data_store.db.should_not_receive(:authenticate)
      @data_store.store(@temp_object)    
    end
    
    it "should attempt to authenticate once if a username is given" do
      @data_store.username = 'terry'
      @data_store.password = 'butcher'
      @data_store.db.should_receive(:authenticate).exactly(:once).with('terry','butcher').and_return(true)
      uid = @data_store.store(@temp_object)
      @data_store.retrieve(uid)
    end
  end

end
