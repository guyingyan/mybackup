package dao

import (
	"testing"
	"fmt"
	"github.com/astaxie/beego/orm"
	_"github.com/go-sql-driver/mysql"
)

func TestQuerTimeListID(t *testing.T) {
	fmt.Println("Initializing DB registration.")
	orm.RegisterDriver("mysql", orm.DRMySQL)
	err := orm.RegisterDataBase("default", "mysql",
		"root:root123@tcp(127.0.0.1:3306)/board?charset=utf8")
	orm.RunSyncdb("default", false, true)
	if err != nil {
		fmt.Printf("Error occurred on registering DB: %+v\n", err)
	}

}
