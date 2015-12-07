module.exports = function(grunt) {
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-cssmin');
  var gruntConfig = require('./grunt-config.json');
  grunt.initConfig(gruntConfig);
  grunt.registerTask('default', ['concat','cssmin']);

};