library(here)
library(transformr)
library(gganimate)
library(data.table)
library(tidyverse)
setwd(here("LectureNotes/8_Asymptotics"))

n_list <- c(50, 200, 1000, 50000)
theta <- 2
theta.len <- 1000
theta.seq <- seq(1.5, 2.5, length = theta.len)
qn0 <- -0.5 * (5 - 4 * theta.seq + theta.seq^2)
y.lower <- -0.8
y.upper <- -0.3

plot_data <-
  CJ(
    N = n_list,
    sim = 1:50
  ) %>%
  rowwise() %>%
  mutate(x = list(
    x = rnorm(N, mean = theta, sd = 1)
  )) %>%
  mutate(qn = list(
    -0.5 * (sum(x^2) / N - 2 * mean(x) * theta.seq + theta.seq^2)
  )) %>%
  mutate(data = list(
    data.table(
      qn = qn,
      theta = theta.seq,
      qn0 = qn0,
      theta.max = theta.seq[which.max(qn)],
      qn.vert = seq(y.lower, max(qn), length = theta.len)
    )
  )) %>%
  dplyr::select(N, sim, data) %>%
  unnest() %>%
  data.table() %>%
  .[, group := paste0("# obs = ", N)] %>%
  .[, group := factor(
    group,
    levels =
      c(
        "# obs = 50",
        "# obs = 200",
        "# obs = 1000",
        "# obs = 50000"
      )
  )]

g_consistency <-
  ggplot(data = plot_data, aes(x = theta, y = qn)) +
  geom_line() +
  geom_line(data = plot_data, aes(x = theta.max, y = qn.vert), colour = "blue") +
  geom_line(data = plot_data, aes(x = theta, y = qn0), colour = "red") +
  geom_line(
    data = data.table(
      x = theta.seq[1],
      y = seq(y.lower, y.upper, length = 1000)
    ),
    aes(x = x, y = y)
  ) +
  geom_line(
    data = data.table(
      x = theta.seq,
      y = y.lower
    ),
    aes(x = x, y = y)
  ) +
  facet_grid(group ~ .) +
  transition_time(sim) +
  labs(title = "Simulation Number: {frame_time}") +
  xlab("theta") +
  ylab("Qn") +
  ylim(y.lower, y.upper) +
  theme(
    legend.position = "none",
    axis.title = element_text(size = 16),
    axis.title.y = element_text(vjust = 0.35),
    axis.title.x = element_text(vjust = 0.15),
    axis.text = element_text(size = 12),
    strip.text.y = element_text(size = 12, color = "blue", angle = 90),
    strip.text.x = element_text(size = 12, color = "blue")
  )