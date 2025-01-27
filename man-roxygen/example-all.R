require("data.table")

data("mtcars")

DT <- as.data.table(mtcars)

# ====================================================================================
# Simple dplyr-like transformations

DT %>%
    start_expr %>%
    filter(vs == 0, am == 1) %>%
    transmute(mean_mpg = mean(mpg)) %>%
    group_by(cyl) %>%
    arrange(-cyl) %T>%
    print %>%
    end_expr

# Equivalent to previous
DT %>%
    start_expr %>%
    transmute(mean_mpg = mean(mpg)) %>%
    where(vs == 0, am == 1) %>%
    group_by(cyl) %>%
    order_by(-cyl) %>%
    end_expr

# Modification by reference
DT %>%
    start_expr %>%
    mutate(wt_squared = wt ^ 2) %>%
    where(gear %% 2 != 0, carb %% 2 == 0) %>%
    end_expr

print(DT)

# Deletion by reference
DT %>%
    start_expr %>%
    mutate(wt_squared = NULL) %>%
    end_expr %>%
    print

# Support for tidyslect helpers (with caveats! check 'Eager verbs' in the vignette)

DT %>%
    start_expr %>%
    select(ends_with("t")) %>%
    end_expr

# ====================================================================================
# Helpers to transform a subset of data

# Like DT[, (whole) := lapply(.SD, as.integer), .SDcols = whole]
whole <- names(DT)[sapply(DT, function(x) { all(x %% 1 == 0) })]
DT %>%
    start_expr %>%
    mutate_sd(as.integer, .SDcols = whole) %>%
    end_expr

sapply(DT, class)

# Like DT[, lapply(.SD, fun), .SDcols = ...]
DT %>%
    start_expr %>%
    transmute_sd((.COL - mean(.COL)) / sd(.COL),
                 .SDcols = setdiff(names(DT), whole)) %>%
    end_expr

# Filter several with the same condition
DT %>%
    start_expr %>%
    filter_sd(.COL == 1, .SDcols = c("vs", "am")) %>%
    end_expr

# Using secondary indices, i.e. DT[.(4, 5), on = .(cyl, gear)]
DT %>%
    start_expr %>%
    filter_on(cyl = 4, gear = 5) %>% # note we don't use ==
    end_expr

# Chaining
DT %>%
    start_expr %>%
    mutate_sd(as.integer, .SDcols = whole) %>%
    chain %>%
    filter_sd(.COL == 1, .SDcols = c("vs", "am"), .collapse = `|`) %>%
    transmute_sd(scale, .SDcols = !is.integer(.COL)) %>%
    end_expr

# The previous is quivalent to
DT[, (whole) := lapply(.SD, as.integer), .SDcols = whole
   ][vs == 1 | am == 1,
     lapply(.SD, scale),
     .SDcols = names(DT)[sapply(DT, Negate(is.integer))]]

# Alternative to keep all columns (*copying* non-scaled ones)
scale_non_integers <- function(x) {
    if (is.integer(x)) x else scale(x)
}

DT %>%
    start_expr %>%
    filter_sd(.COL == 1, .SDcols = c("vs", "am"), .collapse = `|`) %>%
    transmute_sd(everything(), scale_non_integers) %>%
    end_expr

# Without copying non-scaled
DT %>%
    start_expr %>%
    filter(vs == 1 | am == 1) %>%
    chain %>%
    mutate_sd(scale, .SDcols = names(DT)[sapply(DT, Negate(is.integer))]) %>%
    end_expr %>%
    print
