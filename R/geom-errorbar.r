#' Error bars.
#'
#' @section Aesthetics:
#' \Sexpr[results=rd,stage=build]{ggplot2:::rd_aesthetics("geom", "errorbar")}
#'
#' @seealso \code{\link{geom_pointrange}}: range indicated by straight line,
#'   with point in the middle; \code{\link{geom_linerange}}: range indicated
#'   by straight line; \code{\link{geom_crossbar}}: hollow bar with middle
#'   indicated by horizontal line; \code{\link{stat_summary}}: examples of
#'   these guys in use, \code{\link{geom_smooth}} for continuous analog
#' @inheritParams geom_point
#' @export
#' @examples
#' # Create a simple example dataset
#' df <- data.frame(
#'   trt = factor(c(1, 1, 2, 2)),
#'   resp = c(1, 5, 3, 4),
#'   group = factor(c(1, 2, 1, 2)),
#'   se = c(0.1, 0.3, 0.3, 0.2)
#' )
#' df2 <- df[c(1,4),]
#'
#' # Define the top and bottom of the errorbars
#' limits <- aes(ymax = resp + se, ymin=resp - se)
#'
#' p <- ggplot(df, aes(fill=group, y=resp, x=trt))
#' p +
#'  geom_bar(position="dodge", stat="identity") +
#'  geom_errorbar(limits, position = "dodge", width=0.25)
#'
#' # Because the bars and errorbars have different widths
#' # we need to specify how wide the objects we are dodging are
#' dodge <- position_dodge(width=0.9)
#' p +
#'   geom_bar(position = dodge, stat = "identity") +
#'   geom_errorbar(limits, position = dodge, width=0.25)
#'
#' ggplot(df2, aes(trt, resp, fill = group)) +
#'   geom_bar(position = dodge, stat = "identity") +
#'   geom_errorbar(limits, position = dodge, width = 0.25)
#'
#' p <- ggplot(df, aes(colour=group, y=resp, x=trt))
#' p + geom_point() + geom_errorbar(limits, width=0.2)
#' p + geom_pointrange(limits)
#' p + geom_crossbar(limits, width=0.2)
#'
#' # If we want to draw lines, we need to manually set the
#' # groups which define the lines - here the groups in the
#' # original dataframe
#' p + geom_line(aes(group=group)) + geom_errorbar(limits, width=0.2)
geom_errorbar <- function (mapping = NULL, data = NULL, stat = "identity",
  position = "identity", show_guide = NA, inherit.aes = TRUE, ...)
{
  Layer$new(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomErrorbar,
    position = position,
    show_guide = show_guide,
    inherit.aes = inherit.aes,
    params = list(...)
  )
}

GeomErrorbar <- proto2(
  class = "GeomErrorbar",
  inherit = Geom,
  members = list(
    default_aes = aes(colour = "black", size = 0.5, linetype = 1, width = 0.5,
      alpha = NA),

    guide_geom = function(self) "path",

    required_aes = c("x", "ymin", "ymax"),

    reparameterise = function(self, df, params) {
      df$width <- df$width %||%
        params$width %||% (resolution(df$x, FALSE) * 0.9)

      transform(df,
        xmin = x - width / 2, xmax = x + width / 2, width = NULL
      )
    },

    draw = function(self, data, scales, coordinates, width = NULL, ...) {
      GeomPath$draw(with(data, data.frame(
        x = as.vector(rbind(xmin, xmax, NA, x,    x,    NA, xmin, xmax)),
        y = as.vector(rbind(ymax, ymax, NA, ymax, ymin, NA, ymin, ymin)),
        colour = rep(colour, each = 8),
        alpha = rep(alpha, each = 8),
        size = rep(size, each = 8),
        linetype = rep(linetype, each = 8),
        group = rep(1:(nrow(data)), each = 8),
        stringsAsFactors = FALSE,
        row.names = 1:(nrow(data) * 8)
      )), scales, coordinates, ...)
    }
  )
)