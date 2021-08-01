import express from 'express'
import { json } from 'body-parser'
import { queryDepartment, queryTeacher, queryId, queryAllDepartments } from './api'
import { createClient } from 'redis'
import Department from './departement'
import { REDIS_ENDPOINT, SERVER_PORT, API_CACHE_TIMEOUT } from './consts'

/**
 * Redis stuff
 */
const redis = createClient(6379, REDIS_ENDPOINT)

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

// app.use(IpFilter(ALLOWED_IPS, { mode: 'allow' })).put('/api/acysem', (req, res) => {

// })

/**
 * Query a list of departments.
 */
app.post('/api/departments', jsonParser, async (req, res) => {
    console.log('/api/departments')
    const acysem = req.body.acysem
    if (acysem === null) {
        res.status(400)
        res.send({
            acysem: 'Required.'
        })
    }
    const language = req.body.language ?? 'zh-tw'
    const force = req.body.force ?? false
    const requestKey = JSON.stringify({
        item: 'departments',
        acysem: acysem,
        language: language
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null || force) {
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
    console.log('/api/departments/departmentId/grade?')
    const grade = req.params.grade ?? '**'
    const department = req.params.department
    const acysem = req.body.acysem
    if (acysem === null) {
        res.status(400)
        res.send({
            acysem: 'Required.'
        })
        return
    }
    const force = req.body.force ?? false
    const requestKey = JSON.stringify({
        item: 'courses',
        acysem: acysem,
        department: department,
        grade: grade
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null || force) {
            const { data, error } = await queryDepartment(acysem, department, grade)
            if (error === null) {
                redis.set(requestKey, JSON.stringify(data), () => {
                    redis.expire(requestKey, 60 * 60 * 24 * API_CACHE_TIMEOUT)
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

app.post('/api/teachers/:teacher', jsonParser, (req, res) => {
    console.log('/api/teachers/teacherName')
    const teacher = req.params.teacher
    const acysem = req.body.acysem
    if (acysem === null) {
        res.status(400)
        res.send({
            acysem: 'Required.'
        })
        return
    }
    const force = req.body.force ?? false
    const requestKey = JSON.stringify({
        item: 'teachers',
        acysem: acysem,
        teacher: teacher
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null || force) {
            const { data, error } = await queryTeacher(acysem, teacher)
            if (error === null) {
                redis.set(requestKey, JSON.stringify(data), () => {
                    redis.expire(requestKey, 60 * 60 * 24 * API_CACHE_TIMEOUT)
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

app.post('/api/courses/:id', jsonParser, (req, res) => {
    console.log('/api/courses/courseId')
    const id = req.params.id
    const acysem = req.body.acysem
    if (acysem === null) {
        res.status(400)
        res.send({
            acysem: 'Required.'
        })
        return
    }
    const force = req.body.force ?? false
    const requestKey = JSON.stringify({
        item: 'courses',
        acysem: acysem,
        id: id
    })

    redis.get(requestKey, async (error, response) => {
        if (response === null || force) {
            const { data, error } = await queryId(acysem, id)
            if (error === null) {
                redis.set(requestKey, JSON.stringify(data), () => {
                    redis.expire(requestKey, 60 * 60 * 24 * API_CACHE_TIMEOUT)
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

app.listen(SERVER_PORT, () => {
    console.log('Server Running...')
})