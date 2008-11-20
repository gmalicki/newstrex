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

  # the order that stores are setup is important
  # faster stores should be setup first
  
  register(:tmp_cache, Merb::Cache::FileStore, :dir => "tmp/")

  # page cache to the public dir
  register(:page_store, Merb::Cache::PageStore[Merb::Cache::FileStore],
                    :dir => Merb.root / "public")


  # sets up the ordering of stores when attempting to read/write cache entries
   register(:default, AdhocStore[:page_store])

end

