def create_filename(name)
  name.gsub(/[^\w\d .\-_]/, "")
end

def dry_run?
  ENV.fetch("DRY_RUN", "0") == "1"
end
