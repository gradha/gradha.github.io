Title: Contact
Date: 2013-06-19
Tags: navel
Summary: Contact

Send your bytes to [gradha@imap.cc](mailto:gradha@imap.cc).

You can also [take a look at my CV](http://gradha.sdf-eu.org/CV.en.pdf) and
decide to send me money? I even have a fancy [career
page](http://careers.stackoverflow.com/gradha).

	:::nimrod
	proc send_bytes(interesting_content: string) =
		var output: TFile
		output.open("/dev/null", fmWrite)
		output.write(interesting_content)
		output.close
