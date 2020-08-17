.is_scalar <-
    function(x)
{
    length(x) == 1L && !is.na(x)
}

.is_scalar_character <-
    function(x)
{
    is.character(x) && .is_scalar(x) && nzchar(x)
}

.is_scalar_logical <-
    function(x)
{
    is.logical(x) && .is_scalar(x)
}

#' @importFrom httr status_code http_status content
.stop <-
    function(response, namespace, name, text)
{
    message <- content(response)$message
    if (is.null(message))
        message <- paste(as.character(content(respnse)), collapse = "\n")
    stop(
        text,
        "\nworkspace: ", namespace, "/", name,
        "\nstatus code: ", status_code(response),
        "\nhttp status: ", http_status(response)$message,
        "\nresponse content:\n", message,
        call. = FALSE
    )
}        
