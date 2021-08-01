import express from 'express'
import { json } from 'body-parser'
import { queryDepartmentCourses, queryAllDepartments } from './api'
import { createClient } from 'redis'
import Department from './departement'

const PORT = 8888

/**
 * Redis stuff
 */
const REDIS = 'server.yagami.dev'
const redis = createClient(6379, REDIS)

const app = express()
const jsonParser = json()

/**
 * Query available acysem(s)
 */
app.post('/api/acysem', (req, res) => {
    console.log('/api/acysem')
    const requestKey = JSON.stringify({
        item: 'acysem'
    })

    redis.get(requestKey, (error, response) => {
        res.status(200)
        res.send(response)
    })
})

/**
 * Query a list of departments.
 */
app.post('/api/departments', jsonParser, async (req, res) => {
    console.log('/api/departments')
    const acysem = req.body.acysem
    const language = req.body.language
    console.log(acysem)
    console.log(language)
    const requestKey = JSON.stringify({
        item: 'departments',
        acysem: acysem,
        language: language
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null) {
            res.status(449)
            res.send('Caching from NCYU server, please try again later.')
            const departments: Array<Department> = await queryAllDepartments(acysem, language)
            redis.set(requestKey, JSON.stringify(departments))
        }
        else {
            const departements = JSON.parse(response)
            res.status(200)
            res.send(departements)
        }
    })
})

/**
 * Query courses of a department
 */
app.post('/api/departments/:department/:grade?', jsonParser, (req, res) => {
    console.log('/api/courses')
    const acysem = req.body.acysem
    const grade = req.params.grade ?? '**'
    const department = req.params.department
    const requestKey = JSON.stringify({
        item: 'courses',
        acysem: acysem,
        department: department,
        grade: grade
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null) {
            const { data, error } = await queryDepartmentCourses(acysem, department, grade)
            if (error === null) {
                redis.set(requestKey, JSON.stringify(data), () => {
                    redis.expire(requestKey, 60 * 60 * 24 * 30)
                })
                res.status(200)
                res.send(data)
            }
            else {
                res.status(400)
                res.send(error)
            }
        }
        else {
            const courses = JSON.parse(response)
            res.status(200)
            res.send(courses)
        }
    })
})

app.listen(PORT, () => {
    console.log('Server Running...')
})