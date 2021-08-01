import axios from "axios"
import { encode } from "querystring"
import Department from "./departement"
import Course, { parseCourses } from "./course"
import { API_ENDPOINT, API_THROTTLE } from "./consts"

type ApiReponse = {
    [key: string]: {
        1: {
            [key: string]: {
                acy: string
                sem: string
                cos_id: string
                cos_code: string
                num_limit: string
                dep_limit: string
                URL: string | null
                cos_cname: string
                cos_credit: string
                cos_hours: string
                TURL: string
                teacher: string
                cos_time: string
                memo: string
                cos_ename: string
                brief: string
                degree: string
                dep_id: string
                dep_primary: string
                dep_cname: string
                dep_ename: string
                cos_type: string
                cos_type_e: string
                crsoutline_type: string | null
                reg_num: string
                depType: string
            }
        } | null
        2: {
            [key: string]: {
                acy: string
                sem: string
                cos_id: string
                cos_code: string
                num_limit: string
                dep_limit: string
                URL: string | null
                cos_cname: string
                cos_credit: string
                cos_hours: string
                TURL: string
                teacher: string
                cos_time: string
                memo: string
                cos_ename: string
                brief: string
                degree: string
                dep_id: string
                dep_primary: string
                dep_cname: string
                dep_ename: string
                cos_type: string
                cos_type_e: string
                crsoutline_type: string | null
                reg_num: string
                depType: string
            }
        } | null
        dep_id: string
        dep_cname: string
        dep_ename: string
        costype: {
            [key: string]: {
                [key: string]: {
                    course_category_cname: string
                    course_category_ename: string
                    course_category_type: string
                    GECIName: string
                    GECIEngName: string
                }
            }
        }
        brief: {
            [key: string]: {
                [key: string]: {
                    brief_code: string
                    brief: string
                }
            }
        }
        language: {
            [key: string]: {
                授課語言代碼: string
            }
        }
    }
}

async function queryDepartment(
    acysem: string,
    department: string,
    grade: string
): Promise<{ data: Array<Course> | null, error: any | null }> {
    try {
        const acy = acysem.substr(0, 3)
        const sem = acysem.slice(-1)
        const response = await axios.post(
            API_ENDPOINT + 'get_cos_list', encode({
                m_acy:        acy,
                m_sem:        sem,
                m_acyend:     acy,
                m_semend:     sem,
                m_dep_uid:    department,
                m_group:      '**',
                m_grade:      grade,
                m_class:      '**',
                m_option:     '**',
                m_crsname:    '**',
                m_teaname:    '**',
                m_cos_id:     '**',
                m_cos_code:   '**',
                m_crstime:    '**',
                m_crsoutline: '**',
                m_costype:    '**'
            }), {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                }
            }
        )

        return {
            data: parseCourses(response.data),
            error: null
        }
    } catch (error) {
        return {
            data: null, 
            error: error.response.data
        }
    }
}

async function queryOthers(
    acysem: string,
    option: string,
    parameter: string
): Promise<{ data: Array<Course> | null, error: any | null }> {
    try {
        const acy = acysem.substr(0, 3)
        const sem = acysem.slice(-1)
        const response = await axios.post(
            API_ENDPOINT + 'get_cos_list', encode({
                m_acy:        acy,
                m_sem:        sem,
                m_acyend:     acy,
                m_semend:     sem,
                m_dep_uid:    '**',
                m_group:      '**',
                m_grade:      '**',
                m_class:      '**',
                m_option:     option,
                m_crsname:    option === 'crsname'  ? parameter : '**',
                m_teaname:    option === 'teaname'  ? parameter : '**',
                m_cos_id:     option === 'cos_id'   ? parameter : '**',
                m_cos_code:   option === 'cos_code' ? parameter : '**',
                m_crstime:    '**',
                m_crsoutline: '**',
                m_costype:    '**'
            }), {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                }
            }
        )

        return {
            data: parseCourses(response.data),
            error: null
        }
    } catch (error) {
        return {
            data: null, 
            error: error.response.data
        }
    }
}

function sleep(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

async function slowPost(endpoint: string, params: string, config: Object): Promise<any> {
    try {
        console.log('request')
        const response = await axios.post(
            API_ENDPOINT + endpoint, 
            params, 
            config
        )
        await sleep(API_THROTTLE)
        console.log(response.data)
        return response.data
    } catch (error) {}
}

/** 
 * Query all departments from the fucking school backend.
 * 
 * The hierarchy looks like this:
 * type -> category -> college -> department -> group -> grade -> class
 * 
 * I will not implement the group/class part because I think nobody uses it
 * 
 * 
 */
async function queryAllDepartments(
    acysem: string,
    language: string,
): Promise<Array<Department>> {
    const types = await slowPost(
        'get_type', encode({
            flang: language,
            acysem: acysem,
            acysemend: acysem
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            }
        }
    )
    const departments: Array<Department> = []
    for (const type of types) {
        departments.push(...(await getCategory(type.uid, acysem, language)))
    }
    return departments
}

async function getCategory(
    typeId: string, 
    acysem: string, 
    language: string
): Promise<Array<Department>> {
    const categories = await slowPost(
        'get_category', encode({
            ftype: typeId,
            flang: language,
            acysem: acysem,
            acysemend: acysem
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            }
        }
    )
    const departments: Array<Department> = []
    for (const categoryId in categories) {
        if (categoryId.length === 0) {
            departments.push(...(await getDepartment(typeId, categoryId, '*', acysem, language)))
        }
        else if (categoryId.length === 36) {
            // this is already a department
            departments.push({
                name: categories[categoryId],
                id: categoryId,
                grades: []
            })
        }
        else {
            // this is a category
            departments.push(...(await getCollege(typeId, categoryId, acysem, language)))
        }
    }
    return departments
}

async function getCollege(
    typeId: string,
    categoryId: string, 
    acysem: string, 
    language: string
): Promise<Array<Department>> {
    const colleges = await slowPost(
        'get_college', encode({
            ftype: typeId,
            fcategory: categoryId,
            flang: language,
            acysem: acysem,
            acysemend: acysem
        }), {
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
            }
        }
    )
    const departments: Array<Department> = []
    for (const collegeId in colleges) {
        if (collegeId.length === 0) {
            // there is no such college, pass query to getDepartment
            departments.push(...(await getDepartment(typeId, categoryId, '*', acysem, language)))
        }
        else {
            departments.push(...(await getDepartment(typeId, categoryId, collegeId, acysem, language)))
        }
    }
    return departments
}

async function getDepartment(
    typeId: string, 
    categoryId: string, 
    collegeId: string, 
    acysem: string, 
    language: string
): Promise<Array<Department>> {
    try {
        const apiDepartments = await slowPost(
            'get_dep', encode({
                ftype: typeId,
                fcategory: categoryId,
                fcollege: collegeId,
                flang: language,
                acysem: acysem,
                acysemend: acysem
            }), {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                }
            }
        )
        const departments: Array<Department> = []
        for (const departmentId in apiDepartments) {
            const grades = await getGrades(typeId, categoryId, collegeId, departmentId, acysem, language)
            departments.push({
                name: apiDepartments[departmentId],
                id: departmentId,
                grades: grades
            })
        }
        return departments
    } catch (error) {}
    return []
}

async function getGrades(typeId: string, categoryId: string, collegeId: string, departmentId: string, acysem: string, language: string): Promise<Array<{ name: { [key: string]: string }, value: string }>> {
    try {
        const apiGrades = await slowPost(
            'get_grade', encode({
                ftype: typeId,
                fcategory: categoryId,
                fcollege: collegeId,
                fdep: departmentId,
                fgroup: '**',
                flang: language,
                acysem: acysem,
                acysemend: acysem
            }), {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                }
            }
        )
        const grades: Array<{ name: { [key: string]: string }, value: string }> = []
        for (const grade in apiGrades) {
            let tmp: { name: { [key: string]: string }, value: string } = {
                name: {},
                value: grade
            }
            tmp.name[language] = apiGrades[grade]
            grades.push(tmp)
        }
        return grades
    } catch (error) {}
    return []
} 

export { queryDepartment, queryOthers, queryAllDepartments, ApiReponse }