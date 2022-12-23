// `gulp.js`
// Gulp configuration file.
//
// Copyright(c) 2021-2023 Red Hat, Inc.
// This program and the accompanying materials are made
// available under the terms of the Eclipse Public License 2.0
// which is available at https://www.eclipse.org/legal/epl-2.0/
//
//  SPDX - License - Identifier: EPL - 2.0
//
'use strict'

const antora = require('@antora/site-generator')
const connect = require('gulp-connect')
const gulp = require('gulp')

function generate(done) {
    antora(['--playbook', 'antora-playbook.yml'], process.env)
        .then(() => done())
        .catch((err) => {
            console.log(err)
            done()
    })
    connect.reload()
}

async function serve(done) {
    connect.server({
        name: 'Preview Site',
        livereload: true,
        host: '0.0.0.0',
        port: 4000,
        root: './build/site'
    });
    gulp.watch(['./modules/**/*'], generate)
}

exports.default = gulp.series(
    generate,
    serve,
);
