# SSON - S-Expression Standard Object Notation
a faithful embedding of JSON (RFC 8259) into a S-Expression syntax.

To the extent possible under law, Leah Neukirchen <leah@vuxu.org>
has waived all copyright and related or neighboring rights to this work.
http://creativecommons.org/publicdomain/zero/1.0/

## Syntax

	value = "#n" / "#t" / "#f" /
	        "(" value* ")" / "#(" (string value)* ")" /
	        json-number / string
	string = json-string / literal
	literal = [^0-9#;()" \t\r\n+-][^#;()" \t\r\n]*
	";" starts a comment until end of line, it is treated as whitespace

The grammar can be parsed with 1 byte lookahead.

## Example

	[{
	  "created_at": "Thu Jun 22 21:00:00 +0000 2017",
	  "id": 877994604561387500,
	  "id_str": "877994604561387520",
	  "text": "Creating a Grocery List Manager Using Angular, Part 1: Add &amp; Display Items https://t.co/xFox78juL1 #Angular",
	  "truncated": false,
	  "entities": {
	    "hashtags": [{
	      "text": "Angular",
	      "indices": [103, 111]
	    }],
	    "symbols": [],
	    "user_mentions": [],
	    "urls": [{
	      "url": "https://t.co/xFox78juL1",
	      "expanded_url": "http://buff.ly/2sr60pf",
	      "display_url": "buff.ly/2sr60pf",
	      "indices": [79, 102]
	    }]
	  },
	  "source": "<a href=\"http://bufferapp.com\" rel=\"nofollow\">Buffer</a>",
	  "user": {
	    "id": 772682964,
	    "id_str": "772682964",
	    "name": "SitePoint JavaScript",
	    "screen_name": "SitePointJS",
	    "location": "Melbourne, Australia",
	    "description": "Keep up with JavaScript tutorials, tips, tricks and articles at SitePoint.",
	    "url": "http://t.co/cCH13gqeUK",
	    "entities": {
	      "url": {
	        "urls": [{
	          "url": "http://t.co/cCH13gqeUK",
	          "expanded_url": "http://sitepoint.com/javascript",
	          "display_url": "sitepoint.com/javascript",
	          "indices": [0, 22]
	        }]
	      },
	      "description": {
	        "urls": []
	      }
	    },
	    "protected": false,
	    "followers_count": 2145,
	    "friends_count": 18,
	    "listed_count": 328,
	    "created_at": "Wed Aug 22 02:06:33 +0000 2012",
	    "favourites_count": 57,
	    "utc_offset": 43200,
	    "time_zone": "Wellington"
	  }
	}]

	(#(created_at "Thu Jun 22 21:00:00 +0000 2017"
	   id 877994604561387500
	   id_str "877994604561387520"
	   text "Creating a Grocery List Manager Using Angular, Part 1: Add &amp; Display Items https://t.co/xFox78juL1 #Angular"
	   truncated #f
	   entities #(hashtags (#(text Angular indices (103 111)))
	     symbols ()
	     user_mentions ()
	     urls (#(url https://t.co/xFox78juL1
	        expanded_url http://buff.ly/2sr60pf
	        display_url buff.ly/2sr60pf
	        indices (79 102))))
	   source "<a href=\"http://bufferapp.com\" rel=\"nofollow\">Buffer</a>"
	   user #(id 772682964
	     id_str "772682964"
	     name "SitePoint JavaScript"
	     screen_name SitePointJS
	     location "Melbourne, Australia"
	     description "Keep up with JavaScript tutorials, tips, tricks and articles at SitePoint."
	     url http://t.co/cCH13gqeUK
	     entities #(url #(urls (#(url http://t.co/cCH13gqeUK
	            expanded_url http://sitepoint.com/javascript
	            display_url sitepoint.com/javascript
	            indices (0 22))))
	       description #(urls ()))
	     protected #f
	     followers_count 2145
	     friends_count 18
	     listed_count 328
	     created_at "Wed Aug 22 02:06:33 +0000 2012"
	     favourites_count 57
	     utc_offset 43200
	     time_zone Wellington)))
