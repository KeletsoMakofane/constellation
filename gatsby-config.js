module.exports = {
  //pathPrefix: "/constellations",
  siteMetadata: {
    siteUrl: "https://constellationsproject.app",
    title: "The Constellations Project",
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
       {
      resolve: `gatsby-plugin-alias-imports`,
      options: {
        alias: {
          "@src": "src",
          "@components": "src/components",
          "@styles": "src/styles",
          "@pages": "src/pages",
          "@fonts": "src/fonts",
        },
        extensions: [
          "js",
        ],
      }
    }
  ],
};
