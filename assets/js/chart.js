import Chart from "chart.js/auto";

export default {
  mounted() {
    const chartData = JSON.parse(this.el.dataset.chartData);
    const ctx = this.el;
    const data = {
      type: chartData.type,
      data: {
        labels: chartData.labels,
        datasets: [{ label: chartData.heading, data: chartData.datasets }],
        backgroundColor: "rgba(255, 159, 64, 0.2)",
        borderColor: "rgb(255, 159, 64)",
        borderWidth: 1,
      },
    };
    new Chart(ctx, data);
  },
};
