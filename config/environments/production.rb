Merb.logger.info("Loaded PRODUCTION Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = false
  c[:log_level] = :debug
  c[:log_auto_flush ] = true
  
  c[:log_file]  = Merb.root / "log" / "production.log"
  # or redirect logger using IO handle
  # c[:log_stream] = STDOUT
}


Merb::Cache.setup do

  #Merb::Cache.setup(:tmp_dir, Merb::Cache::FileStore, :dir => Merb.root / :tmp)

  Merb::Cache.setup(:page_store, Merb::Cache::PageStore[Merb::Cache::FileStore], :dir => Merb.root / :public)

end