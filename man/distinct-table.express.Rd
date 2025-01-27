% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/VERBS-distinct.R
\name{distinct-table.express}
\alias{distinct-table.express}
\alias{distinct.ExprBuilder}
\title{Rows with distinct combinations of columns}
\usage{
\method{distinct}{ExprBuilder}(.data, ...,
  .parse = getOption("table.express.parse", FALSE))
}
\arguments{
\item{.data}{An instance of \link{ExprBuilder}.}

\item{...}{Which columns to check for uniqueness.}

\item{.parse}{Logical. Whether to apply \code{\link[rlang:parse_expr]{rlang::parse_expr()}} to obtain the expressions.}
}
\description{
Rows with distinct combinations of columns
}
\details{
To see more examples, check the
\href{https://asardaes.github.io/table.express/articles/table.express.html}{vignette}, or the
\link{table.express-package} entry.
}
