\name{sqlsurvey}
\alias{sqlsurvey}
\alias{open.sqlsurvey}
\alias{close.sqlsurvey}
\alias{dim.sqlsurvey}
\alias{open.sqlmodelmatrix}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Large survey design based on SQL database}
\description{
Specifies a survey data set based on a connection to a SQL (currently MonetDB)
database. The replicate-weights version (\code{\link{sqlrepsurvey}}) provides more functionality.
}
\usage{
sqlsurvey(id=NULL, strata = NULL, weights = NULL, fpc = "0", driver=MonetDB.R(), database,
table.name, key ,check.factors=10,...)
\method{close}{sqlsurvey}(con, ...)
\method{open}{sqlsurvey}(con, driver,...)
\method{open}{sqlmodelmatrix}(con, design,...)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{id}{vector of strings with names of sampling unit
    identifiers. Use \code{"1"} or \code{NULL} for individual sampling}
  \item{strata}{vector of strings with names of stratum identifiers. Use
  \code{NULL} for unstratified sampling}
  \item{weights}{string with name of weighting variable, or "1" for
    unweighted analysis }
  \item{fpc}{vector of strings with name of population size variable (variable may
    be zero or literal '0' for sampling with replacement or infinite population size)}
  \item{driver}{database driver object (from \code{MonetDB}), or
    \code{NULL} if \code{database} is already a database connection}
  \item{database}{Either a \connection{MonetDBConnection} or the name (URL) of the database containing the data table}
  \item{table.name}{Name for the data table containing the survey data
    and design variables}
  \item{key}{name of a variable that can be used as a unique key }
  \item{check.factors}{See below}
  \item{con}{survey object or survey model matrix object to be
    disconnected from or reconnected to the database}
  \item{design}{A \code{sqlsurvey} object with an active database
    connection}
  \item{...}{for \code{sqlsurvey} and \code{open.sqlsurvey}, other
    arguments to \code{dbConnect}, such as user,password, and database URL}
}

\value{
  \code{sqlsurvey} returns an object of class \code{sqlsurvey}
  
}
\details{
The point of \code{check.factors} is twofold: to allow numeric variables
to be treated as factors, and to cache the factor levels for both
numeric and character variables to speed computation. Ideally, you
should specify a character vector with list of variable names that
should be treated as factors.  This is important because coercing a
variable to factor in inline expressions is not widely supported in the
sqlsurvey package.

If \code{check.factors} is numeric, variables with fewer than that many
distinct levels will be treate as factors and have their levels
cached. Character variables will always be treated as factors, but will
not have their levels cached if there are more than the limit.
If \code{check.factors} is zero, only character variables will be
treated as factors and they will not have their levels cached.

Finally, \code{check.factors} can be a zero-row data frame. The only
supported way to get this data frame is as the \code{zdata} component
of another \code{sqlsurvey} or \code{sqlrepsurvey} object -- eg, if the
factors are computed for one US state and you wish to transfer them to
another US state without recomputing.

  
The \code{check.factors} operation with a numeric limit can be slow (eg over an hour for an
American Community Survey dataset with 9 million records and 300
variables). If the survey object is saved with \code{save()}, it can be
reconnected to the database with \code{open}, so that it only needs to
be created once.  The most flexible and fastest approach is usually to create the zero-row
data frame manually from the data documentation: only the columns for
factor variables need to be supplied, as the code will assume other
variables are numeric.

The design degrees-of-freedom should be one less than the rank of the matrix of
replicate weights, but for large surveys this is computationally
expensive. The code defaults to one less than the number of replicates,
which is correct for JK1, BRR, and the American Community Survey. For
JKn weights, use the number of PSUs minus number of strata, if this can
be determined from the documentation. 

  
\code{close} closes the database connection, first attempting to
garbage-collect any tables corresponding to non-existent R objects.

\code{open} re-opens the database connection.

To avoid storing a password in a script, you can use,eg,
\code{password=readline("Password: ")} to be prompted for a password, or
set up a {.monetdb} file in the home directory.

  }
\seealso{\code{\link{sqlrepsurvey}},\code{\link[RMonetDB]{MonetDB}}}
\examples{
\dontrun{
## assumes data already in database
library(sqlsurvey)
library(MonetDB.R)
monetdriver<-MonetDB.R()

sqhanes<-sqlsurvey(id="sdmvpsu",strata="sdmvstra",weights="fouryearwt",key="seqn",database="monetdb://localhost/ACS",driver=MonetDB(),table.name="nhanes")
sqhanes

## blood pressure by gender
svymean(~bpxsar+bpxdar,design=sqhanes,se=TRUE,byvar=~riagendr)

## hexbin scatterplot
svyplot(bpxsar~bpxdar, design=sqhanes, style="hex")

## linear model
svylm(bpxsar~bpxdar+ridreth1, design=sqhanes)

close(sqhanes)

sqhanes<-open(sqhanes,driver=monetdriver,user="monetdb",password="monetdb")
opar<-par(mfrow=c(2,2))
svyplot(bpxsar~bpxdar, design=sqhanes, style="subsample",col=ifelse(riagendr==1,"blue","magenta"),pch=19)

close(sqhanes)
}
}

\keyword{survey }

