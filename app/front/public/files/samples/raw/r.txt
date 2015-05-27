geom_dotplot <- function (mapping = NULL, data = NULL, stat = "bindot", position = "identity",
na.rm = FALSE, binwidth = NULL, binaxis = "x", method="dotdensity", binpositions = "bygroup", stackdir = "up",
stackratio = 1, dotsize = 1, stackgroups = FALSE, ...) {
  GeomDotplot$new(mapping = mapping, data = data, stat = stat, position = position,
  na.rm = na.rm, binwidth = binwidth, binaxis = binaxis, method = method, binpositions = binpositions,
  stackdir = stackdir, stackratio = stackratio, dotsize = dotsize, stackgroups = stackgroups, ...)
}

GeomDotplot <- proto(Geom, {
  objname <- "dotplot"

  new <- function(., mapping = NULL, data = NULL, stat = NULL, position = NULL, ...){
    # This code is adapted from Layer$new. It's needed to pull out the stat_params
    # and geom_params, then manually add binaxis to both sets of params. Otherwise
    # Layer$new will give binaxis only to the geom.

    stat <- Stat$find(stat)
    match.params <- function(possible, params) {
      if ("..." %in% names(possible)) {
        params
      } else {
        params[match(names(possible), names(params), nomatch = 0)]
      }
    }

    params <- list(...)
    # American names must be changed here so that they'll go to geom_params;
    # otherwise they'll end up in stat_params
    params <- rename_aes(params)

    geom_params <- match.params(.$parameters(), params)
    stat_params <- match.params(stat$parameters(), params)
    stat_params <- stat_params[setdiff(names(stat_params), names(geom_params))]
    # Add back binaxis
    stat_params <- c(stat_params, binaxis=params$binaxis)

    # If identical(position, "stack") or position is position_stack() (the test
    #  is kind of complex), tell them to use stackgroups=TRUE instead. Need to
    #  use identical() instead of ==, because == will fail if object is
    #  position_stack() or position_dodge()
    if (!is.null(position) && (identical(position, "stack") || (is.proto(position) && position$objname == "stack")))
      message("position=\"stack\" doesn't work properly with geom_dotplot. Use stackgroups=TRUE instead.")

    if (params$stackgroups && params$method == "dotdensity" && params$binpositions == "bygroup")
      message('geom_dotplot called with stackgroups=TRUE and method="dotdensity". You probably want to set binpositions="all"')

    do.call("layer", list(mapping = mapping, data = data, stat = stat, geom = ., position = position,
                          geom_params = geom_params, stat_params = stat_params, ...))
  }


  reparameterise <- function(., df, params) {
    df$width <- df$width %||%
      params$width %||% (resolution(df$x, FALSE) * 0.9)

    # Set up the stacking function and range
    if(is.null(params$stackdir) || params$stackdir == "up") {
      stackdots <- function(a)  a - .5
      stackaxismin <- 0
      stackaxismax <- 1
    } else if (params$stackdir == "down") {
      stackdots <- function(a) -a + .5
      stackaxismin <- -1
      stackaxismax <- 0
    } else if (params$stackdir == "center") {
      stackdots <- function(a)  a - 1 - max(a - 1) / 2
      stackaxismin <- -.5
      stackaxismax <- .5
    } else if (params$stackdir == "centerwhole") {
      stackdots <- function(a)  a - 1 - floor(max(a - 1) / 2)
      stackaxismin <- -.5
      stackaxismax <- .5
    }


    # Fill the bins: at a given x (or y), if count=3, make 3 entries at that x
    df <- df[rep(1:nrow(df), df$count), ]

    # Next part will set the position of each dot within each stack
    # If stackgroups=TRUE, split only on x (or y) and panel; if not stacking, also split by group
    plyvars <- params$binaxis %||% "x"
    plyvars <- c(plyvars, "PANEL")
    if (is.null(params$stackgroups) || !params$stackgroups)
      plyvars <- c(plyvars, "group")

    # Within each x, or x+group, set countidx=1,2,3, and set stackpos according to stack function
    df <- ddply(df, plyvars, function(xx) {
            xx$countidx <- 1:nrow(xx)
            xx$stackpos <- stackdots(xx$countidx)
            xx
          })


    # Set the bounding boxes for the dots
    if (is.null(params$binaxis) || params$binaxis == "x") {
      # ymin, ymax, xmin, and xmax define the bounding rectangle for each stack
      # Can't do bounding box per dot, because y position isn't real.
      # After position code is rewritten, each dot should have its own bounding box.
      df$xmin <- df$x - df$binwidth / 2
      df$xmax <- df$x + df$binwidth / 2
      df$ymin <- stackaxismin
      df$ymax <- stackaxismax
      df$y    <- 0

    } else if (params$binaxis == "y") {
      # ymin, ymax, xmin, and xmax define the bounding rectangle for each stack
      # Can't do bounding box per dot, because x position isn't real.
      # xmin and xmax aren't really the x bounds, because of the odd way the grob
      # works. They're just set to the standard x +- width/2 so that dot clusters
      # can be dodged like other geoms.
      # After position code is rewritten, each dot should have its own bounding box.
      df <- ddply(df, .(group), transform,
            ymin = min(y) - binwidth[1] / 2,
            ymax = max(y) + binwidth[1] / 2)

      df$xmin <- df$x + df$width * stackaxismin
      df$xmax <- df$x + df$width * stackaxismax
      # Unlike with y above, don't change x because it will cause problems with dodging
    }
    df
  }
