\name{boat3d}
\alias{boat3d}
\title{ Draw boat glyphs for orientation data }
\description{
  Draws a stylized sailboat to represent an orientation.
}
\usage{
boat3d(orientation, x = 1:length(orientation), y = 0, 
       z = 0, scale = 0.25, col = 'red', add = FALSE, box = FALSE, axes = TRUE,
       graphics = c('djmrgl', 'rgl', 'scatterplot3d'), ...)
}
\arguments{
  \item{orientation}{ An \code{\link{orientation}} object to be shown. }
  \item{x, y, z}{ Coordinates where boats should be shown. }
  \item{scale}{ Size of boats }
  \item{col}{ Colour of boats }
  \item{add}{ If \code{FALSE}, then clear display first.  }
  \item{box}{ Whether to draw a box around the plot }
  \item{axes}{ Whether to draw axes }
  \item{graphics}{ Which graphics package to use }
  \item{...}{ Additional graphics parameters; see Details below }
}
\details{
  For the identity orientation, the sailboats will be shown upright.
  Other orientations are shown as rotations of this glyph.
 
  The (x,y,z) coordinate appears in the middle of the sail, at the
  top of the gunwales of the boat.
  
  If either the \code{\link[djmrgl]{djmrgl}} or \code{\link[rgl]{rgl}} package is 
  installed, it will be used to draw solid faces on the boats which can be moved by the
  user.  If not, but the \code{\link[scatterplot3d]{scatterplot3d}} package is
  installed, it will be used to draw fixed wireframe boats.  This
  search order can be changed by modifying the \code{graphics} parameter.
  
  Additional graphics parameters may be passed.  If \code{\link[djmrgl]{djmrgl}}
  graphics is used, then these are passed to \code{\link[djmrgl]{par3d}} before
  the plotting is done; if \code{\link[scatterplot3d]{scatterplot3d}} is used, these
  are passed to the \code{\link[scatterplot3d]{scatterplot3d}} function (and ignored
  when adding to an existing plot).  Extra parameters are not passed to
  \code{\link[rgl]{rgl}}.
  
  To add to a \code{\link[scatterplot3d]{scatterplot3d}} plot, you must pass the 
  return value from the initial plot as the value of \code{add}.  See
  the \code{\link{orientlm}} function for an example.
}
\value{
  A \code{\link[djmrgl]{djmrgl}} handle for the graphics display, a current
  plot number for \code{\link[rgl]{rgl}}, or a \code{\link[scatterplot3d]{scatterplot3d}} 
  drawing context.
}
\author{ Duncan Murdoch }
\note{ Requires the \code{\link[djmrgl]{djmrgl}}, \code{\link[rgl]{rgl}} or 
\code{\link[scatterplot3d]{scatterplot3d}} package. }

\examples{
x <- eulerzyx(psi=c(0,pi/4,0,0), theta=c(0,0,pi/4,0), phi=c(0,0,0,pi/4))

# Need to test for existence of 3D renderer

if (length(.find.package('djmrgl', quiet = TRUE))) {
    boat3d(x, 0:3, axes = FALSE)
    axis3d('yz',at=0:3,labels=c('Id','z','y','x'))
} else if (length(.find.package('rgl', quiet = TRUE))) {
    boat3d(x, 0:3, axes = FALSE, graphics = 'rgl')
    rgl.bbox(xat=0:3,xlab=c('Id','z','y','x'),yat=1,zat=1,color='grey')  
}
if (length(.find.package('scatterplot3d', quiet = TRUE))) {
    s <- boat3d(x, 0:3, axes = FALSE, graphics = 'scatterplot3d')
    text(s$xyz.convert(0:3, rep(-0.5,4), rep(-0.5,4)), 
         label = c('Id','z','y','x'))
}
}
\keyword{ hplot }% at least one, from doc/KEYWORDS
\keyword{ dynamic }% __ONLY ONE__ keyword per line
