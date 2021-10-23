module.exports = {
  siteMetadata: {
    siteUrl: "https://www.yourdomain.tld",
    title: "constellations",
  },
  plugins: [
    "gatsby-plugin-styled-components",
    {
      resolve: "gatsby-plugin-google-analytics",
      options: {
        trackingId: "G-4NNY00ZDWY",
      },
    },
    "gatsby-plugin-react-helmet",
  ],
};
