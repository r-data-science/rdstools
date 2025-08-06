#' Generate Hex Image
#'
#' @param prompt A prompt for image generation
#'
#' @return Saves an image to the local working directory and returns the path invisibly
#'
#' @export
saveHexImage <- function(prompt) {
  if (!requireNamespace("openai", quietly = TRUE)) {
    stop("Please install the openai package to use this function")
  }
  if (!requireNamespace("showtext", quietly = TRUE)) {
    stop("Please install the showtext package to use this function")
  }
  if (!requireNamespace("sysfonts", quietly = TRUE)) {
    stop("Please install the sysfonts package to use this function")
  }
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Please install the ggplot2 package to use this function")
  }
  if (!requireNamespace("ggpath", quietly = TRUE)) {
    stop("Please install the ggpath package to use this function")
  }
  if (!requireNamespace("cropcircles", quietly = TRUE)) {
    stop("Please install the cropcircles package to use this function")
  }
  x <- openai::create_image(prompt)
  sysfonts::font_add_google("Barlow", "bar")
  showtext::showtext_auto()
  ft <- "bar"
  txt <- "black"
  img_cropped <- cropcircles::hex_crop(
    images = x$data$url,
    border_colour = txt,
    border_size = 24
  )
  p <- ggplot2::ggplot() +
    ggpath::geom_from_path(ggplot2::aes(0.5, 0.5, path = img_cropped)) +
    ggplot2::xlim(0, 1) +
    ggplot2::ylim(0, 1) +
    ggplot2::theme_void() +
    ggplot2::coord_fixed()
  dest_path <- file.path(getwd(), paste0("hex-", as.integer(Sys.time()), ".png"))
  message("Saving image to: ", dest_path)
  ggplot2::ggsave(dest_path, height = 6, width = 6, bg = "transparent")
  invisible(dest_path)
}



# openai_hex_image <- function(prompt) {
#   if (Sys.getenv("OPENAI_API_KEY") == "")
#     stop("Please set envvar OPENAI_API_KEY", call. = FALSE)
#
#   x <- openai::create_image(prompt)
#   sysfonts::font_add_google("Barlow", "bar")
#   showtext::showtext_auto()
#   ft <- "bar"
#   txt <- "black"
#   img_cropped <- cropcircles::hex_crop(
#     images = x$data$url,
#     border_colour = txt,
#     border_size = 24
#   )
#   p <- ggplot2::ggplot() +
#     ggpath::geom_from_path(ggplot2::aes(0.5, 0.5, path = img_cropped)) +
#     ggplot2::xlim(0, 1) +
#     ggplot2::ylim(0, 1) +
#     ggplot2::theme_void() +
#     ggplot2::coord_fixed()
#   dest_path <- file.path(getwd(), paste0("hex-", as.integer(Sys.time()), ".png"))
#   message("Saving image to: ", dest_path)
#   ggplot2::ggsave(dest_path, height = 6, width = 6, bg = "transparent")
#   invisible(dest_path)
# }
# openai_hex_image("cartoon baby smoking weed")
