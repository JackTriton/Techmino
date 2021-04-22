return STRING.split([=[
游戏方法:
		系统会提供的一个个四连骨牌("方块",总共7种)
		玩家需要控制(左右移动和旋转90,180,270度)这些骨牌直到下落到场地底部,锁定
		每填满场地的一行就会将其消除(如果有对手的话根据消除方式会给对手攻击)
		尝试存活更久,或者完成目标即胜利.

旋转系统:
		使用Techmino专属旋转系统,具体太复杂并且随时可能更改所以不写在这里,可以去parts/kicklist.lua看

spin判定:
		满足三角判定+2分
		满足不可移动判定+2分
		--满足以上之一就算是spin
		满足非第二个test+1分
		--如果分数只有2,方块是SZJLT之一,并且没有把当前方块整个消除那么就是mini

攻击系统:
		普通消除:
				消<4行打出[消行数-0.5]攻击
		特殊消除:
				如果是spin,打出[2*消行数]攻击,
						B2B攻击+[1/1/2/4/8(spin1~5)]
						B3B攻击在B2B基础上+消行数*0.5,+1额外抵挡
						mini减至25%
				不是spin但是单次消>=4行,打出[消行数]攻击,
						B2B攻击+1
						B3B攻击+50%,+1额外抵挡
		特殊消除会增加B2B点数,让之后的特殊消除获得B2B(B3B)增益(详细说明见下文)
		半全消("下方有剩余方块"的全消,如果是I消1行则必须不剩余玩家放置的方块):伤害+4,额外抵挡+2
		全消:全消伤害为8~16(本局内递增2),和上述其他伤害取大,然后+2额外抵挡
		连击:每次连击给予上述攻击[连击数*25%(上限12连)(如果只消一行就是15%)]的加成,>=3次时再额外加1攻击
		根据上述规则计算后,向下取整,攻击打出

分数系统:
		分数计算系统非常复杂,而且随时可能更改所以不写在这里,并且计算只跟消除方式等信息有关,和模式设定无关

攻击延迟:
		消2/3的攻击生效最快,消四其次,spin攻击生效较慢,高连击生效最慢
		B2B或者B3B增加攻击力的同时也会减缓一点生效速度,mini大幅减缓生效速度

抵消逻辑:
		发动攻击时,若缓冲条有攻击则先用额外抵挡再用攻击力1:1抵消最先受到的攻击
		没有用上的额外抵挡会被丢弃,最后剩下的攻击力会发送给对手

back to back(B2B)点数说明:
		B2B点数的范围在0~1000,在点数>=50时进行特殊消除为B2B,>800时特殊消除为B3B
		普通消除:-250
		spin1~5:+[50/100/180/800/1000](mini变为原来50%)
		消四/五/六:+[150/200/...]
		本局内消行数>4时全消:+800
		半全消:+100
		空spin:+20,此法得到的点数不能超过800
		当点数在800以上时空放一块-40(不低于800)

混战模式说明:
		许多玩家同时进行一局游戏(对手都是AI,不是真人).
		随着玩家数量的减少,方块下落/垃圾生效速度/垃圾升起速度都会增加.
		淘汰其它玩家后可以获得一个徽章和该玩家持有的徽章,增强自己的攻击力.
		玩家可选四个攻击模式:
				1.随机:每次攻击后10%随机挑选一个玩家锁定
				2.最多徽章:攻击后或者锁定玩家死亡时锁定徽章最多的玩家
				3.最高:攻击后或者锁定玩家死亡时锁定场地最高的玩家(每秒刷新)
				4.反击:攻击所有锁定自己的玩家(攻击AOE),若未被任何人锁定则攻击随机玩家(不锁定)
		坚持到最后的玩家就是胜利者.

自定义模式说明:
		玩家可以自由调整大多数参数(不包括上述各种游戏模式的特殊效果),
		也可以画一个场地去消除或者是作为提示模板来进行拼图模式.
		在拼图模式下可以按功能键切换是否展示提示,其中:
				打"X"的格子不允许有方块;
				空的格子可以是任何状态;
				普通的七种彩色方块必须颜色对应;
				垃圾行方块的位置只要有方块就可以,但是不能是空气.
		玩家拼出画的图后就会判定胜利.
]=],"\n")