mySPARQL<-function (url = "http://localhost/", query = "", update = "", 
                    ns = NULL, param = "", extra = NULL, format = "xml", encoding="UTF-8", curl_args = NULL, 
                    parser_args = NULL) {
  if (!is.null(extra)) {
    extrastr <- paste("&", sapply(seq(1, length(extra)), 
                                  function(i) {
                                    paste(names(extra)[i], "=", URLencode(extra[[i]]), 
                                          sep = "")
                                  }), collapse = "&", sep = "")
  }
  else {
    extrastr <- ""
  }
  tf <- tempfile()
  if (query != "") {
    if (param == "") {
      param <- "query"
    }
    if (format == "xml") {
      tf <- do.call(getURL, append(list(url = paste(url,"?", param, "=", 
                                                    gsub("\\+", "%2B", URLencode(query,reserved = TRUE)),
                                                    extrastr, sep = ""), 
                                        httpheader = c(Accept = "application/sparql-results+xml"),
                                        .encoding=encoding), 
                                   curl_args))
      DOM <- do.call(xmlParse, append(list(tf), parser_args))
      if (length(getNodeSet(DOM, "//s:result[1]", namespaces = sparqlns)) == 
          0) {
        rm(DOM)
        df <- data.frame(c())
      }
      else {
        attrs <- unlist(xpathApply(DOM, paste("//s:head/s:variable", 
                                              sep = ""), namespaces = sparqlns, quote(xmlGetAttr('<pointer: 0x10de00d00>', 
                                                                                                 "name"))))
        ns2 <- myNoBrackets(ns)
        res <- myGetAttr(attrs, DOM, ns2)
        df <- data.frame(res)
        rm(res)
        rm(DOM)
        n = names(df)
        for (r in 1:length(n)) {
          name <- n[r]
          df[name] <- as.vector(unlist(df[name]))
        }
      }
    }
    else if (format == "csv") {
      tf <- do.call(getURL, append(list(url = paste(url, 
                                                    "?", param, "=", gsub("\\+", "%2B", URLencode(query, 
                                                                                                  reserved = TRUE)), extrastr, sep = "")), curl_args))
      df <- do.call(readCSVstring, append(list(tf, blank.lines.skip = TRUE, 
                                               strip.white = TRUE), parser_args))
      if (!is.null(ns)) 
        df <- dropNS(df, ns)
    }
    else if (format == "tsv") {
      tf <- do.call(getURL, append(list(url = paste(url, 
                                                    "?", param, "=", gsub("\\+", "%2B", URLencode(query, 
                                                                                                  reserved = TRUE)), extrastr, sep = "")), curl_args))
      df <- do.call(readTSVstring, append(list(tf, blank.lines.skip = TRUE, 
                                               strip.white = TRUE), parser_args))
      if (!is.null(ns)) 
        df <- dropNS(df, ns)
    }
    else {
      cat("unknown format \"", format, "\"\n\n", sep = "")
      return(list(results = NULL, namespaces = ns))
    }
    list(results = df, namespaces = ns)
  }
  else if (update != "") {
    if (param == "") {
      param <- "update"
    }
    extra[[param]] <- update
    do.call(postForm, append(list(url, .params = extra), 
                             curl_args))
  }
}

myNoBrackets<-function (ns) {
  sapply(ns, function(br_ns) {
    if (substr(br_ns, 1, 1) == "<") 
      substr(br_ns, 2, nchar(br_ns) - 1)
    else br_ns
  })
}

myGetAttr<-function (attrs, DOM, ns) 
{
  rs <- getNodeSet(DOM, "//s:result", namespaces = sparqlns)
  t(sapply(rs, function(r) {
    sapply(attrs, function(attr) {
      myGetValue(getNodeSet(xmlDoc(r), paste("//s:binding[@name=\"", 
                                            attr, "\"]/*[1]", sep = ""), namespaces = sparqlns)[[1]], 
                ns)
    }, simplify = FALSE)
  }, simplify = TRUE))
}

myGetValue<-function (node, ns) {
  if (is.null(node)) {
    return(NA)
  }
  doc <- xmlDoc(node)
  uri = xpathSApply(doc, "/s:uri", xmlValue, namespaces = sparqlns)
  if (length(uri) == 0) {
    literal = xpathSApply(doc, "/s:literal", xmlValue, namespaces = sparqlns)
    if (length(literal) == 0) {
      bnode = xpathSApply(doc, "/s:bnode", xmlValue, namespaces = sparqlns)
      if (length(bnode) == 0) {
        "***oops***"
      }
      else {
        paste("_:genid", bnode, sep = "")
      }
    }
    else {
      lang = xpathApply(doc, "/s:literal", xmlGetAttr, 
                        "xml:lang", namespaces = sparqlns)
      if (is.null(lang[[1]])) {
        type = xpathApply(doc, "/s:literal", xmlGetAttr, 
                          "datatype", namespaces = sparqlns)
        if (is.null(type[[1]])) {
          literal
        }
        else {
          myinterpret_type(type, literal, ns)
        }
      }
      else {
        paste("\"", literal, "\"@", lang, sep = "")
      }
    }
  }
  else {
    qname = myQnames(uri, ns)
    if (qname == uri) 
      paste("<", uri, ">", sep = "")
    else qname
  }
}

myQnames<-function (str0, ns_list) {
  if (!length(ns_list)) 
    str0
  else mysubstNS(myQnames(str0, ns_list[-1:-2]), ns_list[1:2])
}

mysubstNS<-function (str0, ns) {
  regex <- paste("^", ns[2], sep = "")
  gsub(regex, paste(ns[1], ":", sep = ""), str0)
}

myinterpret_type<-function (type, literal, ns) {
  qname <- myQnames(type, ns)
  if (unlist(qname) == unlist(type)) 
    type_uri <- paste("<", type, ">", sep = "")
  else type_uri <- qname
  if (type == "http://www.w3.org/2001/XMLSchema#double" || 
      type == "http://www.w3.org/2001/XMLSchema#float" || type == 
      "http://www.w3.org/2001/XMLSchema#decimal") 
    as.double(literal)
  else if (type == "http://www.w3.org/2001/XMLSchema#integer" || 
           type == "http://www.w3.org/2001/XMLSchema#int" || type == 
           "http://www.w3.org/2001/XMLSchema#long" || type == "http://www.w3.org/2001/XMLSchema#short" || 
           type == "http://www.w3.org/2001/XMLSchema#byte" || type == 
           "http://www.w3.org/2001/XMLSchema#nonNegativeInteger" || 
           type == "http://www.w3.org/2001/XMLSchema#unsignedLong" || 
           type == "http://www.w3.org/2001/XMLSchema#unsignedShort" || 
           type == "http://www.w3.org/2001/XMLSchema#unsignedInt" || 
           type == "http://www.w3.org/2001/XMLSchema#unsignedByte" || 
           type == "http://www.w3.org/2001/XMLSchema#positiveInteger" || 
           type == "http://www.w3.org/2001/XMLSchema#nonPositiveInteger" || 
           type == "http://www.w3.org/2001/XMLSchema#negativeInteger") 
  as.integer(literal)
  else if (type == "http://www.w3.org/2001/XMLSchema#boolean") 
    as.logical(literal)
  else if (type == "http://www.w3.org/2001/XMLSchema#string" || 
           type == "http://www.w3.org/2001/XMLSchema#normalizedString") 
    literal
  else if (type == "http://www.w3.org/2001/XMLSchema#dateTime") 
    as.POSIXct(literal, format = "%FT%T")
  else if (type == "http://www.w3.org/2001/XMLSchema#time") 
    as.POSIXct(literal, format = "%T")
  else if (type == "http://www.w3.org/2001/XMLSchema#date") 
    as.POSIXct(literal)
  else if (type == "http://www.w3.org/2001/XMLSchema#gYearMonth") 
    as.POSIXct(literal, format = "%Y-%m")
  else if (type == "http://www.w3.org/2001/XMLSchema#gYear") 
    as.POSIXct(literal, format = "%Y")
  else if (type == "http://www.w3.org/2001/XMLSchema#gMonthDay") 
    as.POSIXct(literal, format = "--%m-%d")
  else if (type == "http://www.w3.org/2001/XMLSchema#gDay") 
    as.POSIXct(literal, format = "---%d")
  else if (type == "http://www.w3.org/2001/XMLSchema#gMonth") 
    as.POSIXct(literal, format = "--%m")
  else paste("\"", literal, "\"^^", type_uri, sep = "")
}