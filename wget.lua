if table.getn(arg) > 2 then
	print("Too many arguments passed in.")
	print("Usage: wget <url> <file_name>")
elseif table.getn(arg) < 2 then
	print("Not enough arguments passed in.")
	print("Usage: wget <url> <file_name>")
else
	local url = arg[1]
	local file_name = arg[2]

	local url_content = http.get(url)
	local output_file = io.open(file_name, "w")

	io.output(output_file)
	io.write(url_content.readAll())
	
	io.close(output_file)
	url_content.close()
end