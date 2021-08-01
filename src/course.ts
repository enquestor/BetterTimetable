import { ApiReponse } from "./api";

type Course = {
    year:              number
    semester:          number
    id:                string
    permanentId:       string
    limit:             number
    link:              string
    name: { 
        [key: string]: string
    }
    credits:           number
    hours:             number
    memo:              string
    teacher:           string
    teacherLink:       string
    time:              string
    departmentId:      string
    registered:        number
    departmentName: {
        [key: string]: string
    }
    type:              string
    // typeInformation: {
    //     categoryoyName: {
    //         'zh-tw':  string
    //         'en-us':  string
    //     }
    //     eligible:     string
    // } | null
    typeInformation:   string
    language:          string
}

function parseCourses(data: ApiReponse): Array<Course> {
    let courses: Array<Course> = []

    for (const departmentId in data) {
        if (data[departmentId][1] !== null) {
            for (const courseId in data[departmentId][1]) {
                const apiCourse = data[departmentId][1]![courseId]

                let briefs: Array<String> = []
                for (const briefCode in data[departmentId].brief[courseId]) {
                    briefs.push(data[departmentId].brief[courseId][briefCode].brief)
                }

                courses.push({
                    year:             parseInt(apiCourse.acy),
                    semester:         apiCourse.sem === 'X' ? 3 : parseInt(apiCourse.sem),
                    id:               apiCourse.cos_id,
                    permanentId:      apiCourse.cos_code,
                    limit:            parseInt(apiCourse.num_limit),
                    link:             apiCourse.URL ?? '',
                    name: { 
                        'zh-tw':      apiCourse.cos_cname,
                        'en-us':      apiCourse.cos_ename
                    },
                    credits:          parseFloat(apiCourse.cos_credit),
                    hours:            parseFloat(apiCourse.cos_hours),
                    memo:             apiCourse.memo,
                    teacher:          apiCourse.teacher,
                    teacherLink:      apiCourse.TURL,
                    time:             apiCourse.cos_time,
                    departmentId:     apiCourse.dep_id,
                    registered:       parseInt(apiCourse.reg_num),
                    departmentName: {
                        'zh-tw':      apiCourse.dep_cname,
                        'en-us':      apiCourse.dep_ename
                    },
                    type:             apiCourse.cos_type,
                    typeInformation:  briefs.join('、'),
                    language:         data[departmentId].language[courseId].授課語言代碼
                })
            }
        }
    }

    return courses
}

export default Course
export { parseCourses }