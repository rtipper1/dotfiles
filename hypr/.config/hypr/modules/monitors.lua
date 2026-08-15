------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output   = "DP-2",
    mode     = "2560x1440@144",
    position = "auto",
    scale    = "auto",
})

hl.monitor({
	output = "DP-1",
	mode = "1920x1080@60",
	position = "1440x0",
	scale = "auto",
	transform = 1,
})
