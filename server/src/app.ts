import express from 'express'
import { json } from 'body-parser'
import { queryDepartment, queryOthers, queryAllDepartments } from './api'
import { createClient } from 'redis'
import Department from './departement'
import { REDIS_ENDPOINT, SERVER_PORT, API_CACHE_TIMEOUT } from './consts'

/**
 * Redis stuff
 */
const redis = createClient(6379, REDIS_ENDPOINT)
const now = (): string => (new Date()).toISOString()

/**
 * Express stuff
 */
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
        if (response === null) {
            res.status(400)
            res.send('Please contact administrator.')    
        }
        else {
            const { acysemAvailable, time } = JSON.parse(response)
            res.status(200)
            res.send(acysemAvailable)
        }
    })
})

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

    redis.get(requestKey, async (_, response) => {
        if (response === null || force) {
            res.status(449)
            res.send('Caching from NCYU server, please try again later.')
            const departments: Array<Department> = await queryAllDepartments(acysem, language)
            redis.set(requestKey, JSON.stringify({
                data: departments,
                time: now()
            }))
        }
        else {
            res.status(200)
            res.send(JSON.parse(response))
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
                const result = {
                    data: data,
                    time: now()
                }
                redis.set(requestKey, JSON.stringify(result), () => {
                    redis.expire(requestKey, 60 * 60 * 24 * API_CACHE_TIMEOUT)
                })
                res.status(200)
                res.send(result)
            }
            else {
                res.status(400)
                res.send(error)
            }
        }
        else {
            res.status(200)
            res.send(JSON.parse(response))
        }
    })
})

/**
 * Handle redis response/errors for queryOthers
 */
async function redisHandler(
    error: Error | null, 
    response: string | null,
    force: boolean,
    requestKey: string,
    query: { acysem: string, option: string, parameter: string }
): Promise<{ status: number, data: any }> {
    if (response === null || force) {
        const { data, error } = await queryOthers(query.acysem, query.option, query.parameter)
        if (error === null) {
            const result = {
                data: data,
                time: now()
            }
            redis.set(requestKey, JSON.stringify(result), () => {
                redis.expire(requestKey, 60 * 60 * 24 * API_CACHE_TIMEOUT)
            })
            return { status: 200, data: result }
        }
        else {
            return { status: 400, data: error }
        }
    }
    else {
        return { status: 200, data: JSON.parse(response) }
    }
}

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
        const { status, data } = await redisHandler(
            error,
            response,
            force,
            requestKey,
            { acysem: acysem, option: 'teaname', parameter: teacher }
        )
        res.status(status)
        res.send(data)
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
        const { status, data } = await redisHandler(
            error,
            response,
            force,
            requestKey,
            { acysem: acysem, option: 'cos_id', parameter: id }
        )
        res.status(status)
        res.send(data)
    })
})

app.post('/api/courses/name/:name', jsonParser, (req, res) => {
    console.log('/api/courses/name/courseName')
    const name = req.params.name
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
        name: name
    })

    redis.get(requestKey, async (error, response) => {
        const { status, data } = await redisHandler(
            error,
            response,
            force,
            requestKey,
            { acysem: acysem, option: 'crsname', parameter: name }
        )
        res.status(status)
        res.send(data)
    })
})

app.post('/api/courses/permanent/:id', jsonParser, (req, res) => {
    console.log('/api/courses/permanent/permanentId')
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
        permanentId: id
    })

    redis.get(requestKey, async (error, response) => {
        const { status, data } = await redisHandler(
            error,
            response,
            force,
            requestKey,
            { acysem: acysem, option: 'cos_code', parameter: id }
        )
        res.status(status)
        res.send(data)
    })
})

app.listen(SERVER_PORT, () => {
    console.log('Server Running...')
})