context("  ExprBuilder")

test_that("Constructor only accepts certain data types.", {
    for (input in list(list(0L), NA, NULL, "foo", 0L)) {
        expect_error(ExprBuilder$new(input))
    }
})

test_that("Print method works.", {
    b <- ExprBuilder$new(DT)
    e <- capture.output(print(b))
    expect_identical(e, rlang::as_label(b$expr))
})

test_that("Warning is given when replacing clauses", {
    b <- ExprBuilder$new(DT)

    expr <- rlang::expr(foo(bar))
    b$set_select(expr, FALSE)
    expect_warning(b$set_select(expr, FALSE))

    b$set_where(expr, FALSE)
    expect_warning(b$set_where(expr, FALSE))

    b$set_by(expr, FALSE)
    expect_warning(b$set_by(expr, FALSE))
})

test_that("The expr field is read only.", {
    b <- ExprBuilder$new(DT)
    expect_error(b$expr <- "hi")
})

test_that("Overriding values with eval's ellipsis works.", {
    b <- DT %>% start_expr %>% select(1L)
    ans <- b$eval(rlang::current_env(), TRUE, .DT_ = DT[, -1L])
    expect_identical(ans, DT[, .(cyl)])
})

test_that("chain_if_set works.", {
    b1 <- DT %>% start_expr
    b2 <- b1$chain_if_set(".select")
    expect_identical(b1, b2)

    select(b1, 1L)
    b2 <- b1$chain_if_set(".select")
    expect_false(identical(b1, b2))
})
