boat3d <- function(orientation, x=1:length(orientation), y = 0, z = 0, scale = 0.25,
                   col = 'red', add = FALSE, box = FALSE, axes = TRUE, 
                   graphics = c('djmrgl', 'rgl', 'scatterplot3d'), ...) {
    orientation <- as(orientation, 'rotmatrix')
    len <- length(orientation)
    y <- rep(y, length=len)
    z <- rep(z, length=len)
    scale <- rep(scale, length=len)
    col <- rep(col, length=len)

    #        Back     Left bow Rt bow	 Sail    
    tx <- c(-1, 1, 0, 0, 0, 1, 0, -1, 0, 0, 0, 0)
    ty <- c( 4, 4, 4, 0, 1,1.5,0,1.5, 1, 1, 1, 4)-2
    tz <- c( 1, 1, 0, 1, 0, 1, 1,  1, 0, 0, 4, 0)-1
    #	     Rt side	  Lt side
    qx <- c(-1, 0, 0, -1, 1,  0, 0, 1)
    qy <- c( 4, 4, 1, 1.5,1.5,1, 4, 4)-2
    qz <- c( 1, 0, 0,  1, 1,  0, 0, 1)-1
    
    graphics <- basename(.find.package(graphics, quiet = TRUE))
    if (!length(graphics)) stop('Need 3D renderer:  djmrgl, rgl, or scatterplot3d')
    graphics <- graphics[1]
    require(graphics, character.only = TRUE)
    
    if (graphics == 'djmrgl') {		   
	par3d(autoscale = FALSE)
	skip <- par3d(skipredraw = TRUE, ...)
	on.exit(par3d(skip))

	if (is.logical(add)) {
	    handle <- ThreeDHandle
	    if (!add) clear3d()
    	} else handle <- add
	
    	g <- integer(length(x))
    	
	for (i in 1:length(x)) {
	    oldg <- begingroup3d(scale3d(scale[i], scale[i], scale[i]) 
			  %*% rotate3d(matrix = orientation@x[,,i]) 
			  %*% translate3d(x[i], y[i], z[i]), handle = handle)
	    triangles3d(tx, ty, tz, col=col[i], handle = handle)
	    quads3d(qx, qy, qz, col=col[i], handle = handle)
	    g[i] <- endgroup3d(oldg, handle = handle)
	}
	if (!add) {
	    if (box) box3d(handle = handle)
	    if (axes) axes3d(handle = handle)
	}
	class(g) <- 'obj3d'
	bringToTop3d(handle = handle)
	invisible(handle)
    } else if (graphics == 'rgl') {
	if (is.logical(add)) {
	    if (!add) {
		if (is.null(rgl.cur())) {
		    rgl.open()
		}
		else 
		{
		    rgl.clear()
		}
		rgl.bg(col='white')
	    }
    	}	
	else rgl.set(add)	
	nx <- length(x)	
	verts <- rbind(tx,ty,tz)
	for (i in 1:nx) {
	    newv <- verts*scale[i]
	    newv <- t(orientation[[i]]) %*% newv
	    newv[1,] <- newv[1,] + x[i]
	    newv[2,] <- newv[2,] + y[i]
	    newv[3,] <- newv[3,] + z[i]
	    rgl.triangles(newv[1,],newv[2,],newv[3,],col=col[i])
	}
	
	verts <- rbind(qx,qy,qz)
	for (i in 1:nx) {
	    newv <- verts*scale[i]
	    newv <- t(orientation[[i]]) %*% newv
	    newv[1,] <- newv[1,] + x[i]
	    newv[2,] <- newv[2,] + y[i]
	    newv[3,] <- newv[3,] + z[i]
	    rgl.material(col=col[i])
	    rgl.quads(newv[1,],newv[2,],newv[3,],col=col[i])
	}
	if (axes) rgl.bbox(col='grey')

	invisible(rgl.cur())
    }
    else if (graphics == 'scatterplot3d') {
	tindices <- rep(c(1:3,1), 4) + rep(3*(0:3), each = 4)
	verts <- rbind(tx[tindices],ty[tindices],tz[tindices])
	qindices <- rep(c(1:4,1), 2) + rep(4*(0:1), each = 5)
	verts <- cbind(verts, rbind(qx[qindices],qy[qindices],qz[qindices]))
	ntv <- length(tindices)
	nqv <- length(qindices)
	nv <- ntv+nqv
	nx <- length(x)
	p <- matrix(NA, 3, nx*nv)
	for (i in 1:nx) {
	    newv <- verts*scale[i]
	    newv <- t(orientation[[i]]) %*% newv
	    newv[1,] <- newv[1,] + x[i]
	    newv[2,] <- newv[2,] + y[i]
	    newv[3,] <- newv[3,] + z[i]
	    p[,(nv*(i-1)+1):(nv*i)] <- newv
	}
	xrange <- diff(range(p[1,]))
	yrange <- diff(range(p[2,]))
	zrange <- diff(range(p[3,]))
	range <- max(xrange,yrange,zrange)
	xlim <- mean(range(p[1,]))+c(-range/2,range/2)
	ylim <- mean(range(p[2,]))+c(-range/2,range/2)
	zlim <- mean(range(p[3,]))+c(-range/2,range/2)
	if (is.logical(add)) {
	    if (!add) splot <- scatterplot3d(t(p),type='n',xlim=xlim, ylim=ylim, zlim=zlim, box=box, axis=axes, ...)
	    else stop('Must set add to result of previous call to add to boat3d plot.')
	}
	else splot <- add
	pfun <- splot$points3d
	for (i in 1:nx) {
	    # draw triangles
	    for (j in 1:4) pfun(t(p[,(nv*(i-1)+4*(j-1)+1):(nv*(i-1)+4*j)]), type='l', col=col[i])
	    # draw quads
	    for (j in 1:2) pfun(t(p[,(nv*(i-1)+5*(j-1)+17):(nv*(i-1)+5*j+16)]), type='l', col=col[i])
	}
	invisible(splot)
    } else
    	stop('Need djmrgl, rgl or scatterplot3d')
}
