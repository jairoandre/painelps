var path = require('path');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CleanWebpackPlugin = require('clean-webpack-plugin');

console.log('\u001b[32mWEBPACK ASSEMBLE!\u001b[39m\n');

var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';

if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  module.exports = {
    entry: [
      'webpack-dev-server/client?http://localhost:3000/',
      path.join(__dirname, 'src/elm/index.js')
    ],

    output: {
      path: './dist',
      filename: 'bundle.[hash].js'
    },

    resolve: {
      modulesDirectories: ['node_modules'],
      extensions: ['', '.js', '.elm']
    },

    devServer: {
      inline: true,
      progress: true
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: 'elm-webpack?pathToMake=node_modules/.bin/elm-make&debug=true'
        },
        {
          test: /\.less?$/,
          loader: ExtractTextPlugin.extract('style-loader', 'css-loader!less-loader')
        },
        {
          test: /.*\.(gif|png|jpe?g|svg)$/i,
          loaders: [
            'file?hash=sha512&digest=hex&name=[hash].[ext]',
            'image-webpack?{optimizationLevel: 7, interlaced: false, pngquant:{quality: "65-90", speed: 4}, mozjpeg: {quality: 65}}'
          ]
        }
      ]
    },

    plugins: [
      new HtmlWebpackPlugin({
        title: 'Painel PS - Dev',
        template: './src/elm/index.ejs',
        filename: './index.html'
      }),
      new ExtractTextPlugin('bundle.[hash].css')
    ]

  };
}

if (TARGET_ENV === 'production') {
  console.log('Building for \u001b[33mproduction...\u001b[39m');

  module.exports = {
    entry: './src/elm/index.js',

    output: {
      path: './src/main/webapp/public',
      filename: 'bundle.[hash].js'
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: 'elm-webpack'
        },
        {
          test: /\.less?$/,
          loader: ExtractTextPlugin.extract('style-loader', 'css-loader!less-loader')
        },
        {
          test: /.*\.(gif|png|jpe?g|svg)$/i,
          loaders: [
            'file?hash=sha512&digest=hex&name=[hash].[ext]',
            'image-webpack?{optimizationLevel: 7, interlaced: false, pngquant:{quality: "65-90", speed: 4}, mozjpeg: {quality: 65}}'
          ]
        }
      ]
    },

    plugins: [
      new CleanWebpackPlugin(['src/main/webapp/public'], {
        verbose: true,
        dry: true
      }),
      new HtmlWebpackPlugin({
        title: 'Painel PS',
        template: './src/elm/index.ejs',
        filename: '../index.html'}),
      new ExtractTextPlugin('bundle.[hash].css')
    ]

  };
}
